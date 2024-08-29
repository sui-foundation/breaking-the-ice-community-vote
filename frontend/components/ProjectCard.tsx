import { montreal, neueBitBold } from "@/lib/fonts";
import { Checkbox } from "./ui/checkbox";


export default function ProjectCard({
  id, 
  name, 
  votes, 
  description, 
  videoBlobId,
  onSelect
}: {
  id: number;
  name: string;
  votes: number;
  description: string;
  videoBlobId: string;
  onSelect: () => void;
}) {

  return (
    <div key={id} className="flex flex-col items-center justify-between bg-[#F7F7F7] text-[#0C0F1D] rounded-xl h-[600px] max-w-[450px] px-4 py-4 gap-6">
      <video width="320" height="320" controls className="border rounded-xl border-[#0C0F1D] border-4">
        <source src={`https://aggregator-devnet.walrus.space/v1/${videoBlobId}`}/>
      </video>
      <div className="flex flex-col items-center justify-start grow gap-2">
        <span className={`text-5xl text-center ${neueBitBold.className}`}>
          {name}
        </span>
        <span className={`text-xl ${montreal.className} px-8`}>
          {description}
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