"use client";

import { useEffect, useState } from "react";
import { Transaction } from "@mysten/sui/transactions";
import { useSuiClient } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { getFaucetHost, requestSuiFromFaucetV0 } from "@mysten/sui/faucet";
import {
  BadgeInfo,
  ExternalLink,
  Github,
  Info,
  LoaderCircle,
  LogOut,
  RefreshCw,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import OverflowBanner from "@/public/bannerv2.png";
import SuiLogo from "@/public/Sui_Logo_White.png";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";
import { BalanceChange } from "@mysten/sui/client";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { set, z } from "zod";
import { useForm } from "react-hook-form";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { zodResolver } from "@hookform/resolvers/zod";
import { Checkbox } from "@/components/ui/checkbox";
import Image from "next/image";
import { IconBrandYoutube } from "@tabler/icons-react";
import { track } from "@vercel/analytics/react";
import { useCustomWallet } from "@/contexts/CustomWallet";
import { useAuthentication } from "@/contexts/Authentication";
import { USER_ROLES } from "@/constants/USER_ROLES";
import { ConnectModal } from "@mysten/dapp-kit";
import Link from "next/link";
import { useVoteTransaction } from "@/hooks/useVoteTransaction";
import clientConfig from "@/config/clientConfig";



type Project = {
  id: number;
  name: string;
  airTableUrl: string;
  votes: number;
};

const FormSchema = z.object({
  projects: z
    .array(z.number())
    .nonempty({
      message: "Please select at least one project",
    })
    .max(3, {
      message: "You can only select up to 3 projects",
    }),
});

const projectVideolinks = {
  'SuiMate': 'https://www.youtube.com/live/o8iwoRRsBu8?t=955s',
  'The Wanderer': 'https://www.youtube.com/live/o8iwoRRsBu8?t=1425s',
  'SuiWeb': 'https://www.youtube.com/live/o8iwoRRsBu8?t=2100s',
  'AdToken': 'https://www.youtube.com/live/o8iwoRRsBu8?t=2507s',
  'PinataBot': 'https://www.youtube.com/live/o8iwoRRsBu8?t=3145s',
  'Kriya Credit': 'https://www.youtube.com/live/o8iwoRRsBu8?t=3648s',
  'BioWallet': 'https://www.youtube.com/live/o8iwoRRsBu8?t=4320s',
  'CLMM and Deepbook Market Making Vaulta': 'https://www.youtube.com/live/o8iwoRRsBu8?t=5140s',
  'Private Transaction In Sui': 'https://www.youtube.com/live/o8iwoRRsBu8?t=5600s',
  'HexCapsule': 'https://www.youtube.com/live/o8iwoRRsBu8?t=6160s',
  'Sui Metadata': 'https://www.youtube.com/live/o8iwoRRsBu8?t=6670s',
  'Sui dApp Starter': 'https://www.youtube.com/live/o8iwoRRsBu8?t=7090s',
  'Promise': 'https://www.youtube.com/live/o8iwoRRsBu8?t=8145s',
  'Goose Bumps': 'https://www.youtube.com/live/o8iwoRRsBu8?t=8470s',
  'Panther Wallet': 'https://www.youtube.com/live/o8iwoRRsBu8?t=8890s',
  'Orbital': 'https://www.youtube.com/live/o8iwoRRsBu8?t=9465s',
  'Trippple': 'https://www.youtube.com/live/o8iwoRRsBu8?t=9980s',
  'Aeon': 'https://www.youtube.com/live/o8iwoRRsBu8?t=10350s',
  'Stashdrop': 'https://www.youtube.com/live/o8iwoRRsBu8?t=10760s', 
  'Wagmi Kitchen': 'https://www.youtube.com/live/o8iwoRRsBu8?t=11725s',
  'Kraken': 'https://www.youtube.com/live/o8iwoRRsBu8?t=12175s',
  'Su Protocol': 'https://www.youtube.com/live/o8iwoRRsBu8?t=12700s',
  'Mineral': 'https://www.youtube.com/live/o8iwoRRsBu8?t=13130s',
  'Shio': 'https://www.youtube.com/live/o8iwoRRsBu8?t=13495s',
  'zk Reputation': 'https://www.youtube.com/live/o8iwoRRsBu8?t=13965s',
  'Suinfra – RPC Metrics Dashboard & Geo-Aware RPC Endpoint': 'https://www.youtube.com/live/o8iwoRRsBu8?t=14415s',
  "Homeless Hold'Em": 'https://www.youtube.com/live/o8iwoRRsBu8?t=15370s',
  'Infinite Seas': 'https://www.youtube.com/live/o8iwoRRsBu8?t=15810s',
  'DoubleUp': 'https://www.youtube.com/live/o8iwoRRsBu8?t=16180s',
  'Pump Up': 'https://www.youtube.com/live/o8iwoRRsBu8?t=16490s',
  'SuiFund': 'https://www.youtube.com/live/o8iwoRRsBu8?t=16980s',
  'stream.gift': 'https://www.youtube.com/live/H27LvUvPyQk?t=680s',
  'Shall We Move': 'https://www.youtube.com/live/H27LvUvPyQk?t=1105s',
  'Hop Aggregator': 'https://www.youtube.com/live/H27LvUvPyQk?t=1580s',
  'Summon Attack': 'https://www.youtube.com/live/H27LvUvPyQk?t=2040s',
  'WebAuthn on SUI': 'https://www.youtube.com/live/H27LvUvPyQk?t=2505s',
  'Aalps Protocol': 'https://www.youtube.com/live/H27LvUvPyQk?t=2815s',
  'LePoker': 'https://www.youtube.com/live/H27LvUvPyQk?t=3382s',
  'Mystic Tarot': 'https://www.youtube.com/live/H27LvUvPyQk?t=4296s',
  'BitsLab IDE': 'https://www.youtube.com/live/H27LvUvPyQk?t=4785s',
  'Fren Suipport': 'https://www.youtube.com/live/H27LvUvPyQk?t=5195s',
  'LiquidLink': 'https://www.youtube.com/live/H27LvUvPyQk?t=5535s',
  'SuiGPT': 'https://www.youtube.com/live/H27LvUvPyQk?t=5860s',
  'FoMoney': 'https://www.youtube.com/live/H27LvUvPyQk?t=6320s',
  'SuiSec Toolkit': 'https://www.youtube.com/live/H27LvUvPyQk?t=6665s',
  'sui-wormhole-native-token-transfer': 'https://www.youtube.com/live/H27LvUvPyQk?t=7915s',
  'SuiAutochess': 'https://www.youtube.com/live/H27LvUvPyQk?t=8260s',
  'BullNow': 'https://www.youtube.com/live/H27LvUvPyQk?t=8715s',
  'Mrc20protocol': 'https://www.youtube.com/live/H27LvUvPyQk?t=9210s',
  'Nimbus': 'https://www.youtube.com/live/H27LvUvPyQk?t=9565s',
  'Hakifi': 'https://www.youtube.com/live/H27LvUvPyQk?t=10115s',
  'Pandora Finance': 'https://www.youtube.com/live/H27LvUvPyQk?t=10575s',
  'Sui simulator': 'https://www.youtube.com/live/H27LvUvPyQk?t=11530s',
  'Wecastle': 'https://www.youtube.com/live/H27LvUvPyQk?t=11990s',
  'Stoked Finance': 'https://www.youtube.com/live/H27LvUvPyQk?t=12445s',
  'Scam NFT detector': 'https://www.youtube.com/live/H27LvUvPyQk?t=12970s',
  'Liquidity Garden': 'https://www.youtube.com/live/H27LvUvPyQk?t=13385s',
  'FlowX Finance - Aggregator': 'https://www.youtube.com/live/H27LvUvPyQk?t=13637s',
  'Wave Wallet': 'https://www.youtube.com/live/H27LvUvPyQk?t=14010s',
  'SuiPass': 'https://www.youtube.com/live/H27LvUvPyQk?t=15145s',
  'Multichain Meme Creator': 'https://www.youtube.com/live/H27LvUvPyQk?t=15630s',
  'Legato LBP': 'https://www.youtube.com/live/H27LvUvPyQk?t=16160s',
  'wormhole-kit': 'https://www.youtube.com/live/H27LvUvPyQk?t=16530s',
  'AresRPG': 'https://www.youtube.com/live/H27LvUvPyQk?t=16810s',
  'DegenHive': 'https://www.youtube.com/live/H27LvUvPyQk?t=17340s'

} as { [key: string]: string };

export default function VotingGrid() {

  const form = useForm<z.infer<typeof FormSchema>>({
    resolver: zodResolver(FormSchema),
    defaultValues: {
      projects: [],
    },
  });  

  const client = useSuiClient();
  const { logout } = useCustomWallet();
  const { handleExecute } = useVoteTransaction();

  const [votingInProgress, setVotingInProgress] = useState<boolean>(false);

  const [projects, setProjects] = useState<Project[]>([]);

  useEffect(() => {
    fetchProjects();
  }, []);

  // 2. Define a submit handler.
  function onSubmit(values: z.infer<typeof FormSchema>) {
    // Do something with the form values.
    // ✅ This will be type-safe and validated.

    toast.promise(handleExecute(values.projects), {
      loading: "Submitting vote...",
      success: async (data) => {

        await fetchProjects();

        localStorage.setItem(
          "votedProjects",
          values.projects
            .map((projectId) => projects[projectId].name)
            .join(";;")
        );

        localStorage.setItem("voteDigest", data.digest);

        form.reset({
          projects: [],
        });

        window.location.href = "/thanksforvoting";

        return (
          <span className="flex flex-row items-center gap-2">
            Vote submitted successfully!{" "}
            <a
              href={`https://suiscan.xyz/testnet/tx/${data.digest}`}
              target="_blank"
            >
              <ExternalLink width={12} />
            </a>
          </span>
        );
      },
      error: (error) => {

        if (error.errors == undefined || error.errors.length === 0) {
          return 'An error occurred. Please try again later.'
        }

        if (error.errors[0].message.includes("assert_voting_is_active")) {
          return "Voting is not active at the moment. Please try again later.";
        } else if (error.errors[0].message.includes('assert_user_has_not_voted')) {
          return "You have already voted. You can only vote once.";
        } 

        return 'An error occurred. Please try again later.'
      },
    });
  }

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
          airTableUrl: project.fields.air_table_url,
          votes: project.fields.votes,
        };
      }
    );

    setProjects(projects);
  };
  
  return (
    <div>
      <h1 className="text-4xl font-medium m-4 tracking-tighter">
        Sui Overflow: Community Favorite Award Voting
      </h1>
      <Form {...form}>
        <form
          onSubmit={form.handleSubmit(onSubmit)}
          className="space-y-8 pb-16"
        >
          <FormField
            control={form.control}
            name="projects"
            render={() => (
              <FormItem>
                <div className="mb-4 px-4">
                  <FormLabel className="text-base">How to vote: </FormLabel>
                  <FormDescription>
                    <ul className="list-disc list-inside max-w-prose">
                      <li>
                        Explore the shortlisted projects displayed below. Next to each project name, click the info icon to view the project details and the Youtube icon to watch the project demo from Demo Day
                      </li>
                      <li>Click the checkbox to select a project for voting</li>
                      <li>You can select up to 3 projects</li>
                      <li>Click the submit button to submit your vote - you can only submit your votes once</li>
                    </ul>
                    {/* Click the info icon to view the details of each project and vote for up to your top 3 favorite projects. Note, you can only vote once!  */}
                  </FormDescription>
                </div>
                <div className="flex flex-wrap justify-center gap-4 px-4">
                  {projects.map((project, index) => (
                    <FormField
                      key={project.id}
                      control={form.control}
                      name="projects"
                      render={({ field }) => {
                        return (
                          <FormItem
                            key={project.id}
                            className={
                              "flex flex-row projects-start space-x-3 space-y-0 border p-4 rounded-md items-center w-full sm:w-96 cursor-pointer" +
                              `${
                                index % 2 === 0
                                  ? " bg-[#f9f9f9]"
                                  : " bg-[#f0f0f0]"
                              }`
                            }
                          >
                            <FormControl>
                              <Checkbox
                                checked={field.value?.includes(project.id)}
                                disabled={
                                  field.value?.length === 3 &&
                                  !field.value?.includes(project.id)
                                }
                                onCheckedChange={(checked) => {
                                  return checked
                                    ? field.onChange([
                                        ...field.value,
                                        project.id,
                                      ])
                                    : field.onChange(
                                        field.value?.filter(
                                          (value) => value !== project.id
                                        )
                                      );
                                }}
                              />
                            </FormControl>
                            <FormLabel className="font-normal">
                              {project.name} - {project.votes} votes
                            </FormLabel>
                            <a href={project.airTableUrl} target="_blank">
                              <BadgeInfo className="w-4 text-sky" />
                            </a>
                            {
                              projectVideolinks[project.name] && (
                                <a href={projectVideolinks[project.name]} target="_blank">
                                  <IconBrandYoutube className="w-4 text-red-500" />
                                </a>
                              )
                            }
                          </FormItem>
                        );
                      }}
                    />
                  ))}
                </div>
                <div
                  style={{
                    WebkitBackdropFilter: "blur(4px)",
                    backdropFilter: "blur(4px)",
                    opacity: 10,
                  }}
                  className="fixed border-t p-4 bottom-0 z-10 h-12 flex flex-row items-center justify-between w-full"
                >
                  <Button
                    className="rotate-180"
                    variant={"ghost"}
                    size={"icon"}
                    onClick={logout}
                  >
                    <LogOut className="w-6 text-red-500" />
                  </Button>
                  <Button
                    type="submit"
                    disabled={votingInProgress || !form.formState.isValid}
                  >
                    Submit
                  </Button>
                  {/* <FormMessage /> */}
                </div>
              </FormItem>
            )}
          />
        </form>
      </Form>
    </div>
  );
}