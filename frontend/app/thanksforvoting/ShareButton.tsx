"use client";

import { Button } from "@/components/ui/button";
import { IconBrandX } from "@tabler/icons-react";
import { useEffect, useState } from "react";

export default function ShareButton() {

  const [link, setLink] = useState("");

  useEffect(() => {
    const projectList = localStorage.getItem("votedProjects")?.split(";;") || [];
    const projectLinkInsert = projectList
      .map((project, index) => {
        return `%0A-%20${project}`;
      })
      .join("");
    const link = `https://twitter.com/intent/tweet?text=I%20just%20voted%20for%20my%20favorite%20Breaking%20the%20Ice%20projects%21${projectLinkInsert}%0A%0ASubmit%20your%20votes%20for%20the%20Community%20Favorite%20Award%3A%20https%3A%2F%2Fcommunityvote.walrus.site%2F`;
    setLink(link);
  }, []);

  return (
    <a href={link} target="_blank">
      <Button variant={"outline"} className="bg-[#0C0F1D] text-[#F7F7F7] rounded-xl border border-[#99EFE4] transform hover:scale-110 transition-transform hover:bg-[#99EFE4] hover:text-[#0C0F1D]">
        Share your vote on <IconBrandX  />
      </Button>
    </a>
  );
}
