'use client';

import Image from "next/image";
import Georgey from "@/public/Breakingtheice_voting.png";
import ShareButton from "./ShareButton";
import { use, useEffect, useState } from "react";
import { mondwest, montreal } from "@/lib/fonts";
import clientConfig from "@/config/clientConfig";

export default function Page() {

  const [txnDigest, setTxnDigest] = useState<string | null>(null);

  useEffect(() => {
    const txnDigest = localStorage.getItem('voteDigest');
    if (txnDigest) {
      setTxnDigest(txnDigest);
    }
  }, []);

  return (
    <div className={`flex flex-col items-center justify-center w-full h-full min-h-screen px-4 gap-8 ${montreal.className} text-[#F7F7F7]`}>
      <div className="flex flex-col items-center">
        <h1 className="text-3xl font-medium tracking-tight">
          Thanks for voting!
        </h1>
        <p className="text-lg  text-center">
          Your vote has been <a href={`https://suiscan.xyz/${clientConfig.SUI_NETWORK_NAME}/tx/${txnDigest}`} target="_blank" className={`underline text-[#99EFE4] after:content-['_↗']`}>recorded</a>. We&apos;ll announce the winners soon!
        </p>
      </div>

      <Image
        className="rounded-2xl"
        src={Georgey}
        alt="Georgey"
        width={300}
        height={300}
      />

      <ShareButton />
    </div>
  );
}
