import { montreal, neueBitBold } from "@/lib/fonts";
import { Checkbox } from "./ui/checkbox";
import { SquareArrowOutUpRight } from "lucide-react";
import { Project } from "@/types/Project";


export default function ProjectCard({
  project,
  odd,
  onSelect
}: {
  project: Project;
  odd: boolean;
  onSelect: () => void;
}) {

  return (
    <div key={project.id} className={
      "flex flex-col items-center justify-between bg-[#0C0F1D] text-[#F7F7F7] rounded-xl min-h-[415px] max-w-[450px] px-4 py-4 gap-6" + 
      (odd ? " border border-[#99EFE4] border-2" : " border border-[#C684F6] border-2")
    }>
      <video controls className="border rounded-xl border-[#0C0F1D] border-4 max-h-xs" >
        <source src={`https://aggregator-devnet.walrus.space/v1/${project.videoBlobId}`}/>
      </video>
      <div className="flex flex-col items-center justify-start grow gap-2">
        <div className={`text-2xl md:text-5xl text-center ${neueBitBold.className} flex flex-row gap-1 items-top`}>
          <span>{project.name}</span>
          <a href={project.walrusSiteUrl} target="_blank"><SquareArrowOutUpRight className="w-4 transform hover:scale-110 transition-transform text-[#C684F6]" /></a>
        </div>
        <span className={`text-sm ${montreal.className} px-4 max-h-[100px] overflow-y-auto`}>
          {project.description}
        </span>
      </div>
      <div className="flex flex-row items-center justify-start gap-2">
        <Checkbox className="border-[#F7F7F7]" onClick={onSelect} />
        <span>
          Select
        </span>
      </div>
    </div>
  )
}