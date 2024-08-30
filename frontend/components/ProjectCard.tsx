import { montreal, neueBitBold } from "@/lib/fonts";
import { Checkbox } from "./ui/checkbox";
import { Project } from "./ProjectCarousel";
import { SquareArrowOutUpRight } from "lucide-react";


export default function ProjectCard({
  project,
  onSelect
}: {
  project: Project;
  onSelect: () => void;
}) {

  return (
    <div key={project.id} className="flex flex-col items-center justify-between bg-[#F7F7F7] text-[#0C0F1D] rounded-xl h-[600px] max-w-[450px] px-4 py-4 gap-6">
      <video width="320" height="320" controls className="border rounded-xl border-[#0C0F1D] border-4">
        <source src={`https://aggregator-devnet.walrus.space/v1/${project.videoBlobId}`}/>
      </video>
      <div className="flex flex-col items-center justify-start grow gap-2">
        <div className={`text-2xl md:text-5xl text-center ${neueBitBold.className} flex flex-row gap-1 items-top`}>
          <span>{project.name}</span>
          <a href={project.walrusSiteUrl} target="_blank"><SquareArrowOutUpRight className="w-4 transform hover:scale-110 transition-transform text-[#C684F6]" /></a>
        </div>
        <span className={`text-sm md:text-xl ${montreal.className} px-8 max-h-[175px] md:max-h-[275px] overflow-y-auto`}>
          {project.description}
        </span>
      </div>
      <div className="flex flex-row items-center justify-start gap-2">
        <Checkbox onClick={onSelect} />
        <span>
          Select
        </span>
      </div>
    </div>
  )
}