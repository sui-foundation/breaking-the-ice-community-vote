import { createContext, useContext, useEffect, useMemo, useState } from "react";
import { Transaction } from "@mysten/sui/transactions";
import {
  SuiTransactionBlockResponse,
  SuiTransactionBlockResponseOptions,
} from "@mysten/sui/client";
import { useCurrentAccount, useCurrentWallet, useDisconnectWallet, useSignTransaction, useSuiClient } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin, useZkLoginSession } from "@mysten/enoki/react";
import clientConfig from "@/config/clientConfig";
import { useRouter } from "next/navigation";
import toast from "react-hot-toast";
import { SponsorTxRequestBody } from "@/types/SponsorTx";
import { fromB64, toB64 } from "@mysten/sui/utils";
import axios, { AxiosResponse } from "axios";
import { useAuthentication } from "./Authentication";
import { UserRole } from "@/types/Authentication";

export interface CreateSponsoredTransactionApiResponse {
  bytes: string;
  digest: string;
}

export interface ExecuteSponsoredTransactionApiInput {
  digest: string;
  signature: string;
}


interface SponsorAndExecuteTransactionBlockProps {
  tx: Transaction;
  network: "mainnet" | "testnet";
  options: SuiTransactionBlockResponseOptions;
  includesTransferTx: boolean;
  allowedAddresses?: string[];
}

interface ExecuteTransactionBlockWithoutSponsorshipProps {
  tx: Transaction;
  options: SuiTransactionBlockResponseOptions;
}
interface CustomWalletContextProps {
  isConnected: boolean;
  isUsingEnoki: boolean;
  address?: string;
  jwt?: string;
  getAddressSeed: () => Promise<string>;
  sponsorAndExecuteTransactionBlock: (
    props: SponsorAndExecuteTransactionBlockProps
  ) => Promise<SuiTransactionBlockResponse | void>;
  executeTransactionBlockWithoutSponsorship: (
    props: ExecuteTransactionBlockWithoutSponsorshipProps
  ) => Promise<SuiTransactionBlockResponse | void>;
  logout: () => void;
  redirectToAuthUrl: (role: UserRole) => void;
}

export const useCustomWallet = () => {
  const context = useContext(CustomWalletContext);
  return context;
};

export const CustomWalletContext = createContext<CustomWalletContextProps>({
  isConnected: false,
  isUsingEnoki: false,
  address: undefined,
  jwt: undefined,
  getAddressSeed: async () => "",
  sponsorAndExecuteTransactionBlock: async () => {},
  executeTransactionBlockWithoutSponsorship: async () => {},
  logout: () => {},
  redirectToAuthUrl: () => {},
});

export default function CustomWalletProvider({children}: {children: React.ReactNode}) {
  const suiClient = useSuiClient();
  const router = useRouter();
  const { address: enokiAddress } = useZkLogin();
  const zkLoginSession = useZkLoginSession();
  const enokiFlow = useEnokiFlow();
  const { handleLoginAs } = useAuthentication();

  const currentAccount = useCurrentAccount();
  const { isConnected: isWalletConnected } = useCurrentWallet();
  const { mutateAsync: signTransactionBlock } = useSignTransaction();
  const { mutate: disconnect } = useDisconnectWallet();

  const { isConnected, isUsingEnoki, address, logout } = useMemo(() => {
    return {
      isConnected: !!enokiAddress || isWalletConnected,
      isUsingEnoki: !!enokiAddress,
      address: enokiAddress || currentAccount?.address,
      logout: () => {
        if (isUsingEnoki) {
          enokiFlow.logout();     
        } else {
          disconnect();
        }
        sessionStorage.clear();
        router.push("/");
      },
    };
  }, [
    enokiAddress,
    currentAccount?.address,
    enokiFlow,
    isWalletConnected,
    disconnect,
  ]);

  useEffect(() => {
    console.log('isWalletConnected', isWalletConnected)
    console.log('isConnected', isConnected)
    if (isConnected) {
      console.log(sessionStorage.getItem("userRole"));
      handleLoginAs({
        firstName: "Wallet",
        lastName: "User",
        role:
          sessionStorage.getItem("userRole") !== "null"
            ? (sessionStorage.getItem("userRole") as UserRole)
            : "anonymous",
        email: "",
        picture: "",
      });
    }
  }, [isConnected, isWalletConnected, handleLoginAs]);

  const getAddressSeed = async (): Promise<string> => {
    if (isUsingEnoki) {
      const { addressSeed } = await enokiFlow.getProof({
        network: "testnet",
      });
      return addressSeed;
    }
    return "";
  };

  const redirectToAuthUrl = (userRole: UserRole) => {
    const protocol = window.location.protocol;
    const host = window.location.host;
    const customRedirectUri = `${protocol}//${host}/auth`;
    enokiFlow
      .createAuthorizationURL({
        provider: "google",
        network: clientConfig.SUI_NETWORK_NAME,
        clientId: clientConfig.GOOGLE_CLIENT_ID,
        redirectUrl: customRedirectUri,
        extraParams: {
          scope: ["openid", "email", "profile"],
        },
      })
      .then((url) => {
        sessionStorage.setItem("userRole", userRole);
        router.push(url);
      })
      .catch((err) => {
        console.error(err);
      });
  };

  const signTransaction = async (bytes: Uint8Array): Promise<string> => {
    if (isUsingEnoki) {
      const signer = await enokiFlow.getKeypair({
        network: clientConfig.SUI_NETWORK_NAME,
      });
      const signature = await signer.signTransaction(bytes);
      return signature.signature;
    }
    const txBlock = Transaction.from(bytes);
    return signTransactionBlock({
      transaction: txBlock,
      chain: `sui:${clientConfig.SUI_NETWORK_NAME}`,
    }).then((resp) => resp.signature);
  };

  const sponsorAndExecuteTransactionBlock = async ({
    tx,
    network,
    options,
    includesTransferTx,
    allowedAddresses = [],
  }: SponsorAndExecuteTransactionBlockProps): Promise<SuiTransactionBlockResponse | void> => {
    if (!isConnected) {
      toast.error("Wallet is not connected");
      return;
    }
    try {
      let digest = "";
      if (!isUsingEnoki || includesTransferTx) {
        // Sponsorship will happen in the back-end
        console.log("Sponsorship in the back-end...");
        const txBytes = await tx.build({
          client: suiClient,
          onlyTransactionKind: true,
        });
        const sponsorTxBody: SponsorTxRequestBody = {
          network,
          txBytes: toB64(txBytes),
          sender: address!,
          allowedAddresses,
        };
        console.log("Sponsoring transaction block...");
        const sponsorResponse: AxiosResponse<CreateSponsoredTransactionApiResponse> =
          await axios.post("/api/sponsor", sponsorTxBody);
        const { bytes, digest: sponsorDigest } = sponsorResponse.data;
        console.log("Signing transaction block...");
        const signature = await signTransaction(fromB64(bytes));
        console.log("Executing transaction block...");
        const executeSponsoredTxBody: ExecuteSponsoredTransactionApiInput = {
          signature,
          digest: sponsorDigest,
        };
        const executeResponse: AxiosResponse<{ digest: string }> =
          await axios.post("/api/execute", executeSponsoredTxBody);
        console.log("Executed response: ");
        digest = executeResponse.data.digest;
      } else {
        // Sponsorship can happen in the front-end
        console.log("Sponsorship in the front-end...");
        const response = await enokiFlow.sponsorAndExecuteTransaction({
          network: clientConfig.SUI_NETWORK_NAME,
          transaction: tx,
          client: suiClient,
        });
        digest = response.digest;
      }
      await suiClient.waitForTransaction({ digest, timeout: 5_000 });
      return suiClient.getTransactionBlock({
        digest,
        options,
      });
    } catch (err) {
      console.error(err);
      toast.error("Failed to sponsor and execute transaction block");
    }
  };

  // some transactions cannot be sponsored by Enoki in its current state
  // for example when want to use the gas coin as an argument in a move call
  // so we provide an additional method to execute transactions without sponsorship
  const executeTransactionBlockWithoutSponsorship = async ({
    tx,
    options,
  }: ExecuteTransactionBlockWithoutSponsorshipProps): Promise<SuiTransactionBlockResponse | void> => {
    if (!isConnected) {
      toast.error("Wallet is not connected");
      return;
    }
    tx.setSender(address!);
    const txBytes = await tx.build({ client: suiClient });
    const signature = await signTransaction(txBytes);
    return suiClient.executeTransactionBlock({
      transactionBlock: txBytes,
      signature: signature!,
      requestType: "WaitForLocalExecution",
      options,
    });
  };
  
  
  return (
    <CustomWalletContext.Provider
      value={{
        isConnected,
        isUsingEnoki,
        address,
        jwt: zkLoginSession?.jwt,
        sponsorAndExecuteTransactionBlock,
        executeTransactionBlockWithoutSponsorship,
        logout,
        redirectToAuthUrl,
        getAddressSeed,
      }}
    >
      {children}
    </CustomWalletContext.Provider>
  );
}