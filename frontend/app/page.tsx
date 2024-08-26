"use client";

import { montreal, neueBitBold, mondwest } from "@/lib/fonts";
import heroBanner from "@/public/banner.png";
import ButtonPrimary from "@/public/button-primary.png";
import ButtonSecondary from "@/public/button-secondary.png";
import Georgey from "@/public/georgey.png";
import Image from "next/image";
import { useCustomWallet } from "@/contexts/CustomWallet";
import { USER_ROLES } from "@/constants/USER_ROLES";
import Link from "next/link";

export default function Page() {

  const { redirectToAuthUrl } = useCustomWallet();

  return (
    <div className={`w-full flex flex-col items-center ${montreal.className} text-[#F7F7F7]`}>
      <div className="relative w-full px-4 py-1">
        <div className="w-full h-full flex flex-col items-center justify-around top-0 absolute">
          <span
            className={`scroll-m-20 text-xl md:text-4xl font-extrabold tracking-tight md:text-5xl ${neueBitBold.className}`}
          >
            WALRUS
          </span>
          <div className="flex flex-col items-center gap-0 sm:gap-2">
            <span className="text-xs md:text-3xl text-[#99EFE4]">
              Walrus Devnet Hackathon
            </span>
            <div className="flex flex-row">
              <span
                className={`text-5xl md:text-9xl text-[#99EFE4] text-center ${mondwest.className}`}
              >
                Breaking
                <br /> the Ice
              </span>
              <Image src={Georgey} alt="georgey" className="w-16 -ml-4 md:w-full md:-ml-12" />
            </div>
          </div>
          <div className="flex gap-4">
            <Link
              href="#"
              onClick={() => redirectToAuthUrl(USER_ROLES.ROLE_2)}
            >
              <button className="h-12 sm:h-16 relative transform active:scale-95 transition-transform">
                <Image src={ButtonPrimary} alt="button" className="h-8 w-24 sm:h-16 sm:w-48" />
                <div className="flex flex-col items-center justify-center w-full h-full absolute top-0">
                  <span className="text-xs sm:text-base">Sign In with Google</span>
                </div>
              </button>
            </Link>
            <a href="https://discord.gg/walrusprotocol" target="_blank">
              <button className="h-12 sm:h-16 relative transform active:scale-95 transition-transform">
                <Image src={ButtonSecondary} alt="button" className="h-8 w-24 sm:h-16 sm:w-48" />
                <div className="flex flex-col items-center justify-center w-full h-full absolute top-0">
                  <span className="text-xs sm:text-base">View Projects</span>
                </div>
              </button>
            </a>
          </div>
        </div>
        <Image
          src={heroBanner}
          alt="banner"
          className="object-cover w-full border border-[#99EFE4] border-2 rounded-xl md:max-h-[700px]"
        />
      </div>
    </div>
  );
}
