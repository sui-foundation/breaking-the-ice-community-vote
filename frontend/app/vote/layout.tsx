"use client";

import { ChildrenProps } from "@/types/ChildrenProps";
import { useAuthentication } from "@/contexts/Authentication";
import Loading from "@/components/Loading";
import { useRouter } from "next/navigation";

export default function ModeratorRootLayout({ children }: ChildrenProps) {
  const { user, isLoading } = useAuthentication();
  const router = useRouter();

  if (isLoading) {
    return <Loading />;
  }

  if (user?.role !== "moderator") {
    router.push("/");
    return <Loading />;
  }

  return children;
}
