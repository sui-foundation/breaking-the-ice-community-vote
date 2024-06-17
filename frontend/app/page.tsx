"use client";

import { useEffect, useState } from "react";
import { Transaction } from "@mysten/sui/transactions";
import { useSuiClient } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { getFaucetHost, requestSuiFromFaucetV0 } from "@mysten/sui/faucet";
import { ExternalLink, Github, Info, LoaderCircle, RefreshCw } from "lucide-react";
import { Button } from "@/components/ui/button";
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
import { z } from "zod"
import { useForm } from "react-hook-form";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { zodResolver } from "@hookform/resolvers/zod"
import { Checkbox } from "@/components/ui/checkbox";

type Project = {
  id: number;
  name: string;
  airTableUrl: string;
  votes: number;
}

const dummyProjects = [
  {
    id: 0, 
    name: "Aalps Protocol",
    airTableUrl: "https://airtable.com/appInEqjBZ2YxoHgS/shrmgnQKAXwCnv4NY/tblJaA1KCQXwgcHtU/viwsKAEf1fDL8T6cS/recI6k3PRC0113wDh", 
    votes: 0
  },
  {
    id: 1, 
    name: "AdCommand",
    airTableUrl: "https://airtable.com/appInEqjBZ2YxoHgS/shrmgnQKAXwCnv4NY/tblJaA1KCQXwgcHtU/viwsKAEf1fDL8T6cS/recd95WbIXs5qiLmM",
    votes: 0
  },
  {
    id: 2,
    name: "Aeon",
    airTableUrl: "https://airtable.com/appInEqjBZ2YxoHgS/shrmgnQKAXwCnv4NY/tblJaA1KCQXwgcHtU/viwsKAEf1fDL8T6cS/recJHliYSNdxFXdCB",
    votes: 0
  },
  {
    id: 3,
    name: "Aalps Protocol",
    airTableUrl: "https://airtable.com/appInEqjBZ2YxoHgS/shrmgnQKAXwCnv4NY/tblJaA1KCQXwgcHtU/viwsKAEf1fDL8T6cS/recI6k3PRC0113wDh",
    votes: 0
  },
  {
    id: 4,
    name: "Aalps Protocol",
    airTableUrl: "https://airtable.com/appInEqjBZ2YxoHgS/shrmgnQKAXwCnv4NY/tblJaA1KCQXwgcHtU/viwsKAEf1fDL8T6cS/recI6k3PRC0113wDh",
    votes: 0
  },
];

const FormSchema = z.object({
  projects: z.array(z.number())
  .nonempty({
    message: "Please select at least one project",
  })
  .max(3, {
    message: "You can only select up to 3 projects",
  })
})

export default function Page() {

  const form = useForm<z.infer<typeof FormSchema>>({
    resolver: zodResolver(FormSchema),
    defaultValues: {
      projects: [],
    },
  })

  const client = useSuiClient(); // The SuiClient instance
  const enokiFlow = useEnokiFlow(); // The EnokiFlow instance
  const { address: suiAddress } = useZkLogin(); // The zkLogin instance

  /* The account information of the current user. */
  const [balance, setBalance] = useState<number>(0);
  const [accountLoading, setAccountLoading] = useState<boolean>(true);

  const [projects, setProjects] = useState<Project[]>([]);

  useEffect(() => {
    fetchProjects()
  }, [])

  /**
   * When the user logs in, fetch the account information.
   */
  useEffect(() => {
    if (suiAddress) {
      getAccountInfo();
      enokiFlow.getProof({
        network: "testnet"
      }).then((proof) => {
        console.log('proof', proof)
      })

      enokiFlow.getSession().then((session) => {
        console.log('session', session)
      })
    }
  }, [suiAddress]);

  // 2. Define a submit handler.
  function onSubmit(values: z.infer<typeof FormSchema>) {
    // Do something with the form values.
    // ✅ This will be type-safe and validated.
    console.log(values)
  }

  const startLogin = async () => {
    const promise = async () => {
      
      window.location.href = await enokiFlow.createAuthorizationURL({
        provider: "google",
        clientId: process.env.GOOGLE_CLIENT_ID!,
        redirectUrl: `${window.location.href.split("#")[0]}auth`,
        network: "testnet",
      });
    };

    toast.promise(promise, {
      loading: "Loggin in...",
    });
  };

  /**
   * Fetch the account information of the current user.
   */
  const getAccountInfo = async () => {
    if (!suiAddress) {
      return;
    }

    setAccountLoading(true);

    const balance = await client.getBalance({ owner: suiAddress });
    setBalance(parseInt(balance.totalBalance) / 10 ** 9);

    setAccountLoading(false);
  };

  /**
   * Request SUI from the faucet.
   */
  const onRequestSui = async () => {
    const promise = async () => {
      //track("Request SUI");

      // Ensures the user is logged in and has a SUI address.
      if (!suiAddress) {
        throw new Error("No SUI address found");
      }

      if (balance > 3) {
        throw new Error("You already have enough SUI!");
      }

      // Request SUI from the faucet.
      const res = await requestSuiFromFaucetV0({
        host: getFaucetHost("testnet"),
        recipient: suiAddress,
      });

      if (res.error) {
        throw new Error(res.error);
      }

      return res;
    };

    toast.promise(promise, {
      loading: "Requesting SUI...",
      success: (data) => {
        console.log("SUI requested successfully!", data);

        const suiBalanceChange = data.transferredGasObjects
          .map((faucetUpdate) => {
            return faucetUpdate.amount / 10 ** 9;
          })
          .reduce((acc: number, change: any) => {
            return acc + change;
          }, 0);

        setBalance(balance + suiBalanceChange);

        return "SUI requested successfully! ";
      },
      error: (error) => {
        return error.message;
      },
    });
  };

  const fetchProjects = async () => {
    const res = await client.getObject({
      id: process.env.VOTES_OBJECT_ADDRESS!,
      options: {
        showContent: true, 
        // showPreviousTransaction: true
      }
    })

    console.log(res)

    if (!res.data || !res.data.content) {
      return
    }

    const projects = (res.data.content as any).fields.project_list.map((project: any) => {
      return { 
        id: parseInt(project.fields.id), 
        name: project.fields.name,
        airTableUrl: project.fields.air_table_url,
        votes: project.fields.votes
      }
    })

    console.log(projects)
    setProjects(projects)

  }

  if (suiAddress) {
    return (
      <div>
        <h1 className="text-4xl font-bold m-4">Overflow Voting</h1>
        <Popover>
          <PopoverTrigger className="absolute top-4 right-4 max-w-sm" asChild>
            <div>
              <Button className="hidden sm:block" variant={"secondary"}>
                {accountLoading ? (
                  <LoaderCircle className="animate-spin" />
                ) : (
                  `${suiAddress?.slice(0, 5)}...${suiAddress?.slice(
                    63
                  )} - ${balance.toPrecision(3)} SUI`
                )}
              </Button>
              <Avatar className="block sm:hidden">
                <AvatarImage src="https://github.com/shadcn.png" />
                <AvatarFallback>CN</AvatarFallback>
              </Avatar>
            </div>
          </PopoverTrigger>
          <PopoverContent>
            <Card className="border-none shadow-none">
              {/* <Button variant={'ghost'} size='icon' className="relative top-0 right-0" onClick={getAccountInfo}><RefreshCw width={16} /></Button> */}
              <CardHeader>
                <CardTitle>Account Info</CardTitle>
                <CardDescription>
                  View the account generated by Enoki&apos;s zkLogin flow.
                </CardDescription>
              </CardHeader>
              <CardContent>
                {accountLoading ? (
                  <div className="w-full flex flex-col projects-center">
                    <LoaderCircle className="animate-spin" />
                  </div>
                ) : (
                  <>
                    <div className="flex flex-row gap-1 projects-center">
                      <span>Address: </span>
                      {accountLoading ? (
                        <LoaderCircle className="animate-spin" />
                      ) : (
                        <div className="flex flex-row gap-1">
                          <span>{`${suiAddress?.slice(
                            0,
                            5
                          )}...${suiAddress?.slice(63)}`}</span>
                          <a
                            href={`https://suiscan.xyz/testnet/account/${suiAddress}`}
                            target="_blank"
                          >
                            <ExternalLink width={12} />
                          </a>
                        </div>
                      )}
                    </div>
                    <div>
                      <span>Balance: </span>
                      <span>{balance.toPrecision(3)} SUI</span>
                    </div>
                  </>
                )}
              </CardContent>
              <CardFooter className="flex flex-row gap-2 projects-center justify-between">
                <Button variant={"outline"} size={"sm"} onClick={onRequestSui}>
                  Request SUI
                </Button>
                <Button
                  variant={"destructive"}
                  size={"sm"}
                  className="w-full text-center"
                  onClick={async () => {
                    await enokiFlow.logout();
                    window.location.reload();
                  }}
                >
                  Logout
                </Button>
              </CardFooter>
            </Card>
          </PopoverContent>
        </Popover>
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
            <FormField
              control={form.control}
              name="projects"
              render={() => (
                <FormItem>
                  <div className="mb-4">
                    <FormLabel className="text-base">Projects</FormLabel>
                    <FormDescription>
                      Select the projects you want to display in the sidebar.
                    </FormDescription>
                  </div>
                  <div className="flex flex-wrap justify-center gap-4">
                    {projects.map((project, index) => (
                      <FormField
                        key={project.id}
                        control={form.control}
                        name="projects"
                        render={({ field }) => {
                          return (
                            <FormItem
                              key={project.id}
                              className="flex flex-row projects-start space-x-3 space-y-0 border p-4 rounded-md items-center"
                            >
                              <FormControl>
                                <Checkbox
                                  checked={field.value?.includes(project.id)}
                                  onCheckedChange={(checked) => {
                                    return checked
                                      ? field.onChange([...field.value, project.id])
                                      : field.onChange(
                                          field.value?.filter(
                                            (value) => value !== project.id
                                          )
                                        )
                                  }}
                                />
                              </FormControl>
                              <FormLabel className="font-normal">
                                {project.name}
                              </FormLabel>
                              <a href={project.airTableUrl} target="_blank">
                                <ExternalLink className="w-4" />
                              </a>
                            </FormItem>
                          )
                        }}
                      />
                    ))}
                  </div>
                  <FormMessage />
                </FormItem>
              )}
            />
            <Button type="submit">Submit</Button>
          </form>
        </Form>
      </div>
    );
  }

  return (
    <div className="flex flex-col projects-center justify-start">
      <a
        href="https://github.com/dantheman8300/enoki-example-app"
        target="_blank"
        className="absolute top-4 right-0 sm:right-4"
        onClick={() => {
          //track("github");
        }}
      >
        <Button variant={"link"} size={"icon"}>
          <Github />
        </Button>
      </a>
      <div>
        <h1 className="text-4xl font-bold m-4">Overflow Voting</h1>
        <p className="text-md m-4 opacity-50 max-w-md">
          Use this app to vote for your favorite project in the Overflow hackathon!
          Votes are stored on the Sui network and can be viewed on this page.
        </p>
      </div>
      <Button onClick={startLogin}>Sign in with Google</Button>
    </div>
  );
}
