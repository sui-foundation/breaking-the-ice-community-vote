import { montreal, neueBitBold, mondwest } from "@/lib/fonts";
import heroBanner from "@/public/banner.png";
import Georgey from "@/public/georgey.png";
import Image from "next/image";
import walrusButton from "@/public/walrusButton.png";
import ProjectCarousel from "@/components/ProjectCarousel";

export default function Page() {
  return (
    <div
      className={`w-full flex flex-col items-center ${montreal.className} text-[#F7F7F7]`}
    >
      <div className="relative w-full px-4 py-1">
        <div className="w-full h-full flex flex-col items-center justify-around top-0 absolute">
          <span
            className={`scroll-m-20 text-xl md:text-5xl font-extrabold tracking-tight ${neueBitBold.className}`}
          >
            WALRUS
          </span>
          <div className="flex flex-col items-center gap-0 sm:gap-2">
            <span className="text-xs md:text-2xl text-[#99EFE4]">
              Walrus Devnet Hackathon - Community Vote
            </span>
            <div className="flex flex-row">
              <span
                className={`text-4xl md:text-9xl text-[#99EFE4] text-center ${mondwest.className}`}
              >
                Breaking
                <br /> the Ice
              </span>
              <Image
                src={Georgey}
                alt="georgey"
                className="w-12 -ml-4 md:w-40 md:-ml-10 lg:h-full lg:w-full"
              />
            </div>
          </div>
        </div>
        <Image
          src={heroBanner}
          alt="banner"
          className="object-cover w-full border border-[#99EFE4] border-2 rounded-xl md:max-h-[500px]"
        />
      </div>
      <div className="w-full px-4 py-1 flex flex-col lg:flex-row items-center justify-center gap-4">
        <div className="w-full px-4 h-[200px] sm:h-[300px] text-[#99EFE4] bg-[#C684F6] items-center relative rounded-xl border border-2 border-[#99EFE4] overflow-hidden flex flex-col items-center justify-center">
          <div className="flex flex-col items-center w-full justify-center text-center items-center">
            <h2
              className={`z-30 text-3xl md:text-6xl lg:text-8xl text-[#99EFE4] text-center ${neueBitBold.className}`}
              style={{ lineHeight: ".75" }}
            >
              How Voting Works
            </h2>
            <span className="z-30 text-left">
              <ul className="list-disc ps-6 max-w-lg">
                <li>
                  All elligible Breaking the Ice projects are included in the
                  community vote.
                </li>
                <li>
                  The top X (filled in later) projects with the most votes will
                  win $500 and be selected for the peer approval round.
                </li>
                <li>Everyone is allowed to partipate in the community vote.</li>
              </ul>
            </span>
          </div>
        </div>
        <div className="w-full px-4 h-[200px] sm:h-[300px] text-[#99EFE4] bg-[#99EFE4] items-center relative rounded-xl border border-2 border-[#99EFE4] overflow-hidden flex flex-col items-center justify-center">
          <div className="flex flex-col items-center w-full justify-center text-center text-[#C684F6] items-center">
            <h2
              className={`z-30 text-3xl md:text-6xl lg:text-8xl text-[#C684F6] text-center ${neueBitBold.className}`}
              style={{ lineHeight: ".75" }}
            >
              How to Participate
            </h2>
            <span className="z-30 text-left">
              <ul className="list-decimal ps-4 text-[#C684F6] max-w-lg">
                <li>Explore the Breaking the Ice projects.</li>
                <li>Click the checkbox to select a project for voting</li>
                <li>You can select as many projects as you like</li>
                <li>
                  Click the submit button to submit your vote - you can only
                  submit your votes once
                </li>
              </ul>
            </span>
          </div>
        </div>
      </div>
      <div className="w-full px-4 py-1">
        <ProjectCarousel />
      </div>
      <div className="w-full px-4 py-1">
        <div className="w-full rounded-xl border border-2 border-[#99EFE4] bg-[#0C0F1D] h-48 flex flex-row items-center justify-between p-4 text-[#C684F6]">
          <div className="flex flex-col items-start justify-between h-full">
            <span className="text-xs uppercase">
              Robust. Resilient. Ready. Walrus.
            </span>
            <Image
              src={walrusButton}
              alt="button"
              className="w-12 h-12 transform hover:scale-95 transition-transform"
            />
            <span className="text-sm">
              VISIT
              <br />
              <a
                href="https://walrus.xyz"
                target="_blank"
                className="text-sm underline hover:opacity-90"
              >
                WALRUS.XYZ
              </a>
            </span>
          </div>
          <div className="flex flex-col items-start justify-between h-full">
            <span className="text-xs"></span>
            <div></div>
            <a
              href="https://breakingtheice.walrus.site/"
              className="text-sm underline hover:opacity-90"
            >
              Breaking the Ice site
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
