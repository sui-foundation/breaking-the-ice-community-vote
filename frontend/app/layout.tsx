import { Metadata } from "next";
import { ProvidersAndLayout } from "./ProvidersAndLayout";
import "./globals.css";
import '@mysten/dapp-kit/dist/index.css';

export const metadata: Metadata = {
  title: 'Community Vote',
  description: 'Breaking the Ice - Community Vote',
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {

  return (
    <html lang="en">
      <body className={`bg-[#0C0F1D]`}>
        <ProvidersAndLayout>{children}</ProvidersAndLayout>
      </body>
    </html>
  );
}
