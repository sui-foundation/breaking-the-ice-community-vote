import { montreal, neueBitBold } from "@/lib/fonts";
import { Checkbox } from "./ui/checkbox";
import { ExternalLink, SquareArrowOutUpRight } from "lucide-react";
import { Project } from "@/types/Project";
import { IconBrandGithub } from "@tabler/icons-react";

export default function ProjectCard({
  project,
  odd,
  selected,
  onSelect, 
  showSelect,
}: {
  project: Project;
  odd: boolean;
  selected: boolean;
  showSelect: boolean;
  onSelect: () => void;
}) {

  return (
    <div key={project.id} className={
      "flex flex-col items-center justify-between text-[#F7F7F7] rounded-xl min-h-[415px] max-w-[450px] px-4 py-4 gap-6 overflow-hidden" + 
      (odd ? " border border-[#99EFE4] border-2" : " border border-[#C684F6] border-2") + 
      (selected ? " bg-[#2C2F3D]" : " bg-[#0C0F1D]")
    }>
      <div className="h-[250px] w-full flex flex-col items-center justify-center">
        <video controls poster="https://aggregator-devnet.walrus.space/v1/HZWhXCiuVANvQuPD2Oa0AoWKvJ052Vnl4T6oLlNPstQ" className="border rounded-xl border-[#0C0F1D] border-4 max-h-[250px]" >
          <source src={`https://aggregator-devnet.walrus.space/v1/${project.videoBlobId}`} type="video/mp4"/>
          <source src={`https://aggregator-devnet.walrus.space/v1/${project.videoBlobId}`} type="video/mov"/>
          <source src={`https://aggregator-devnet.walrus.space/v1/${project.videoBlobId}`} type="video/ogg"/>
          <source src={`https://aggregator-devnet.walrus.space/v1/${project.videoBlobId}`} />
        </video>
      </div>
      <div className="flex flex-col items-center justify-start grow gap-2 w-full">
        <div className={`text-2xl md:text-5xl text-center ${neueBitBold.className} flex flex-row gap-1 items-top`}>
          <span>{project.name}</span>
          <a href={project.walrusSiteUrl} target="_blank"><ExternalLink className="w-4 transform hover:scale-110 transition-transform text-[#C684F6]" /></a>
          <a href={project.githubUrl} target="_blank"><IconBrandGithub className="w-4 transform hover:scale-110 transition-transform text-[#C684F6]" /></a>
        </div>
        <span className={`text-sm ${montreal.className} px-4 max-h-[100px] overflow-y-auto whitespace-pre-wrap break-words w-full `}>
          {project.description}
        </span>
      </div> 
      {
        showSelect &&
        <div className="flex flex-row items-center justify-start gap-2">
          <Checkbox className="border-[#F7F7F7]" onClick={onSelect} />
          <span>
            Select
          </span>
        </div>
      }
    </div>
  )
}