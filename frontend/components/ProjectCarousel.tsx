'use client';

import { useCustomWallet } from "@/contexts/CustomWallet";
import { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious } from "./ui/carousel";
import ProjectCard from "./ProjectCard";
import { Button } from "./ui/button";
import { LogOut } from "lucide-react";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { useSuiClient } from "@mysten/dapp-kit";
import clientConfig from "@/config/clientConfig";
import { USER_ROLES } from "@/constants/USER_ROLES";
import { useVoteTransaction } from "@/hooks/useVoteTransaction";
import { toast } from "sonner";
import { Project } from "@/types/Project";

export default function ProjectCarousel() {

  const { isConnected, logout, redirectToAuthUrl, emailAddress } = useCustomWallet();

  const client = useSuiClient();

  const router = useRouter();

  const [projects, setProjects] = useState<Project[]>([]);

  const [selectedProjects, setSelectedProjects] = useState<number[]>([]);

  const { handleExecute } = useVoteTransaction();

  useEffect(() => {
    fetchProjects();
  }, []);


  const fetchProjects = async () => {
    const res = await client.getObject({
      id: clientConfig.VOTES_OBJECT_ADDRESS,
      options: {
        showContent: true,
        // showPreviousTransaction: true
      },
    });

    if (!res.data || !res.data.content) {
      return;
    }

    const projects = (res.data.content as any).fields.project_list.map(
      (project: any) => {
        return {
          id: parseInt(project.fields.id),
          name: project.fields.name,
          votes: project.fields.votes,
          description: project.fields.description,
          videoBlobId: project.fields.video_blob_id,
          githubUrl: project.fields.github_url,
          walrusSiteUrl: project.fields.walrus_site_url,
        };
      }
    );

    shuffleArray(projects);

    setProjects(projects);
  };

  const hanldeSubmitVote = async () => {

    if (selectedProjects.length === 0) {
      return toast.error("Please select at least one project to vote");
    }


    toast.promise(handleExecute(selectedProjects), {
      loading: "Submitting your vote...",
      success: (data) => {

        localStorage.setItem(
          "votedProjects",
          selectedProjects
            .map((projectId) => projects.find((project) => project.id === projectId)?.name || "")
            .join(";;")
        );

        localStorage.setItem("voteDigest", data.digest);

        router.push("/thanksforvoting");
        return "Your vote has been submitted"
      },
      error: "There was an error submitting your vote. Please try again.",
    });

  }

  const handleSelectProject = (id: number) => {
    if (selectedProjects.includes(id)) {
      setSelectedProjects(selectedProjects.filter((projectId) => projectId !== id));
    } else {
      setSelectedProjects([...selectedProjects, id]);
    }
  };

  if (isConnected) {
    return (
      <div className="relative rounded-xl w-full flex flex-col items-center justify-center py-4 gap-4">
        <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-4">
          {projects.map((project, index) => (
            <ProjectCard
              key={index}
              project={project}
              odd={index % 2 === 0}
              selected={selectedProjects.includes(project.id)}
              onSelect={() => handleSelectProject(project.id)}
            />
          ))}
        </div>
        <div className="sticky bg-[#0C0F1D] border-2 border-[#F7F7F7] rounded-xl bottom-2 flex w-full flex-row items-center justify-between gap-1 py-4 px-4">
          <div className="flex flex-row items-center">
            <Button variant={"ghost"} size={"icon"} onClick={logout} className="transform hover:scale-110 transition-transform hover:bg-none">
              <LogOut className="rotate-180 text-red-500"/>
            </Button>
            {
              emailAddress && 
              <span className="text-[#99EFE4] overflow-hidden truncate max-w-[150px]">{emailAddress}</span>
            }
          </div>
          <Button className="bg-[#0C0F1D] rounded-xl border border-[#99EFE4] transform hover:scale-110 transition-transform hover:bg-[#99EFE4] bg-[#99EFE4] text-[#0C0F1D]" onClick={hanldeSubmitVote}>
            Submit Vote
          </Button>
        </div>
      </div>
    )
  }

  return (
    <div className="rounded-xl w-full flex flex-col items-center justify-center py-4 gap-2">
      <Button className="bg-[#0C0F1D] rounded-xl border border-[#99EFE4] transform hover:scale-110 transition-transform hover:bg-[#99EFE4] bg-[#99EFE4] text-[#0C0F1D]" onClick={() => redirectToAuthUrl(USER_ROLES.ROLE_2)}>
        View projects
      </Button>
    </div>
  )
}

function shuffleArray(array: any[]) {
  for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [array[i], array[j]] = [array[j], array[i]];
  }
}