import { z } from "zod";

/*
 * The schema for the client-side environment variables
 * These variables should be defined in the app/.env file
 * These variables are NOT SECRET, they are exposed to the client side
 * They can and should be tracked by Git
 * All of the env variables must have the NEXT_PUBLIC_ prefix
 */

const clientConfigSchema = z.object({
  SUI_NETWORK: z.string(),
  SUI_NETWORK_NAME: z.enum(["mainnet", "testnet"]),
  ENOKI_API_KEY: z.string(),
  GOOGLE_CLIENT_ID: z.string(),
  VOTES_OBJECT_ADDRESS: z.string(),
  VOTING_MODULE_ADDRESS: z.string(),
});

const clientConfig = clientConfigSchema.parse({
  SUI_NETWORK: process.env.NEXT_PUBLIC_SUI_NETWORK!,
  SUI_NETWORK_NAME: process.env.NEXT_PUBLIC_SUI_NETWORK_NAME as
    | "mainnet"
    | "testnet",
  ENOKI_API_KEY: process.env.NEXT_PUBLIC_ENOKI_API_KEY!,
  GOOGLE_CLIENT_ID: process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID!,
  VOTES_OBJECT_ADDRESS: process.env.NEXT_PUBLIC_VOTES_OBJECT_ADDRESS!,
  VOTING_MODULE_ADDRESS: process.env.NEXT_PUBLIC_VOTING_MODULE_ADDRESS!,
});

export default clientConfig;