import "server-only";

import { Metadata } from "next";
import React from "react";
import { OwnedObjectsGrid } from "@/components/general/OwnedObjectsGrid";
import VotingGrid from "@/components/VotingGrid";

export const metadata: Metadata = {
  title: "PoC Template for Moderators",
};

const ModeratorHomePage = () => {
  return <VotingGrid />;
};

export default ModeratorHomePage;
