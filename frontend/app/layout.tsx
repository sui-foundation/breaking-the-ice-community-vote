"use client";

import { Inter } from "next/font/google";
import "./globals.css";
import '@mysten/dapp-kit/dist/index.css';
import { EnokiFlowProvider } from "@mysten/enoki/react";
import { createNetworkConfig, SuiClientProvider, WalletProvider } from "@mysten/dapp-kit";
import { getFullnodeUrl } from "@mysten/sui/client";
import { Toaster } from "@/components/ui/sonner";
import { Analytics } from "@vercel/analytics/react"
import CustomWalletProvider from "@/contexts/CustomWallet";
import { AuthenticationProvider } from "@/contexts/Authentication";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import clientConfig from "@/config/clientConfig";

const inter = Inter({ subsets: ["latin"] });

// Config options for the networks you want to connect to
const { networkConfig } = createNetworkConfig({
  testnet: { url: getFullnodeUrl("testnet") },
});

export interface StorageAdapter {
  setItem(key: string, value: string): Promise<void>;
  getItem(key: string): Promise<string | null>;
  removeItem(key: string): Promise<void>;
}

const sessionStorageAdapter: StorageAdapter = {
  getItem: async (key) => {
    return sessionStorage.getItem(key);
  },
  setItem: async (key, value) => {
    sessionStorage.setItem(key, value);
  },
  removeItem: async (key) => {
    sessionStorage.removeItem(key);
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {

  const { networkConfig } = createNetworkConfig({
    testnet: { url: getFullnodeUrl("testnet") },
    mainnet: { url: getFullnodeUrl("mainnet") },
  });

  const queryClient = new QueryClient();

  
  return (
    <html lang="en">
      <QueryClientProvider client={queryClient}>
        <SuiClientProvider networks={networkConfig} defaultNetwork="testnet">
          <EnokiFlowProvider apiKey={clientConfig.ENOKI_API_KEY}>
            <WalletProvider
              autoConnect
              stashedWallet={{
                name: "Breaking the Ice = Community Vote",
              }}
              storage={sessionStorageAdapter}
            >
              <AuthenticationProvider>
                <CustomWalletProvider>
                  <body className={inter.className}>{children}</body>
                  <Analytics />
                  <Toaster closeButton  />
                </CustomWalletProvider>
              </AuthenticationProvider>
            </WalletProvider>
          </EnokiFlowProvider>
        </SuiClientProvider>
      </QueryClientProvider>
    </html>
  );
}
