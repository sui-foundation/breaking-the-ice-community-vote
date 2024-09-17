
/// Module: voting
module voting::voting {
  use std::string;
  use sui::table;
  use sui::vec_map;
  use sui::url;
  use sui::zklogin_verified_issuer::check_zklogin_issuer;
  use sui::vec_set::{Self,VecSet};
  use std::type_name::{Self, TypeName};
  use sui::address;

  const EInvalidProof: u64 = 1;
  const EUserAlreadyVoted: u64 = 2;
  const EInvalidProjectId: u64 = 4;
  const EVotingInactive: u64 = 5;
  const ENotInWhitelist: u64 = 6;

  public struct Votes has key {
    id: UID, 
    total_votes: u64, 
    project_list: table::Table<u64, Project>,
    ballots: table::Table<address, vector<u64>>,
    voting_active: bool,
    whitelist_tokens: VecSet<TypeName>,
  }

  public(package) fun project_list(self: &Votes, i: u64): Project {
    return self.project_list[i]
  }

  public(package) fun append_project_list(self: &mut Votes, p: Project) {
    self.project_list.add(p.id, p);
  }

  public(package) fun share_votes(self: Votes) {
    transfer::share_object(self);
  }

  public fun total_votes(self: &Votes): u64 {
    self.total_votes
  }

  public fun ballots(self: &Votes, user: address): vector<u64> {
    *self.ballots.borrow(user)
  }

  public(package) fun new_votes<T>(
    total_votes: u64,
    project_list: table::Table<u64, Project>,
    ballots: table::Table<address, vector<u64>>,
    voting_active: bool,
    ctx: &mut TxContext
  ): Votes {
    let tn = type_name::get<T>();
    return Votes {
      id: object::new(ctx),
      total_votes,
      project_list,
      ballots,
      voting_active: voting_active,
      whitelist_tokens: vec_set::singleton(tn),
    }
  }

  public struct Project has store, copy, drop {
    id: u64,
    name: string::String, 
    description: string::String, 
    video_blob_id: string::String, 
    walrus_site_url: url::Url, 
    github_url: url::Url,
    votes: u64
  }

  public fun project_votes(self: &Project): u64 {
    self.votes
  }

  public struct AdminCap has key, store {
    id: UID
  }

  fun init(ctx: &mut TxContext) {

    let projects = vector[
      // 1
      vector[
        b"Suitizen", 
        b"Suitizen is an on-chain identity initiative. Our mission is to create an identity card fully compatible with the SUI network, empowering citizens with the rights to participate in various on-chain community activities.\n\nUsers can purchase the SUI Name Service and then apply for an identity card on the Suitizen website. During the application process, we scan your facial features and, incorporating some randomness, generate an avatar that represents you in the SUI world. This avatar is immutable, reflecting the idea that one cannot change their appearance in the real world. Your facial features, along with the generated avatar, are encrypted and recorded on Walrus.\n\nWe are also building an on-chain community that includes activities like \"Discussion\" and \"Voting\". In the future, we plan to expand the community with more activities.\n\nNow, Let's become a Suitizen!", 
        b"https://github.com/CJMario89/suitizen", 
        b"https://suitizen.walrus.site/", 
        b"-BM_1f-EF2QzxCfSQeQuWxjgs8aNLRa2WTZd-tzDvZw"
      ],
      // 2
      vector[
        b"Random Direction Shoot Game", 
        b"GAME RULES\n\nnormal mode:\n\nW/A/S/D or Arrow keys to move.\n\nFire bullets randomly.\n\nPoints are scored based on the initial radius of enemies destroyed.\n\nAfter 100 bullets, the score will be settled.\n\nIf your score can be on the list (top ten), you can choose to pay a certain amount to update the list and get a unique NFT collection at the same time.\n\nrainbow mode:\n\nYour bullets will be of random colors, and bullets of different colors have different effects.\n\nWhen you give a fatal blow, your score may increase significantly.\n\nIt is worth noting that you need to pay a certain amount in advance to enable rainbow mode.", 
        b"https://github.com/zcy1024/WalrusDevnetHackathon", 
        b"https://zcy1024-walrusdevnethackathon.walrus.site/", 
        b"lzHY6gnFLr3ZhLraFELutYNEso6GczYPyGWzdJTUQ3w"
      ],
      // 3
      vector[
        b"Promise", 
        b"Promise is a quiz platform leveraging zero-knowledge proofs to create an engaging experience which combats ad fatigue through meaningful ad engagement.", 
        b"https://github.com/arty-arty/promise-zk", 
        b"https://promise.walrus.site/", 
        b"00jPbQPmgNiSUOxsSvULn9p6q8GRmQtCp8niQF_KD6s"
      ],
      // 4
      vector[
        b"AdToken", 
        b"AdToken is a next-gen peer-to-peer ad network that connects businesses with global influencers and publishers. We offer cost-effective, dynamic ad campaigns using blockchain technology and our AdToken AdSense solution, with real-time, gas-free payments. Our platform features versatile ad formats and events, paired with our pricing algorithm for optimised pricing and targeting, ensuring maximum ROI and efficient operations for all users.", 
        b"https://github.com/AdToken-2024/adtoken-dapp", 
        b"https://adtoken.walrus.site/", 
        b"LW9WpZFC-4hQ9R_7R8cC7FDjPIjxb6yRCZH5zLiwS0w"
      ],
      // 5
      vector[
        b"Time Capsule", 
        b"It is a decentralized platform that allows users to store their future words and wishes on the blockchain. Users can record their thoughts and set unlock dates to motivate future self reflection, growth, and change.", 
        b"https://github.com/houddup/time_capsule_ui", 
        b"https://42eh3u0w42kfgdidgtdtn0mojjkv3bbskng6jnalmj40wk93mn.walrus.site/", 
        b"22JduPG_CE4bCDHl9jRkcXDcB9ZqJ7IbpfOWEVnWY7s"
      ],
      // 6
      vector[
        b"SuiSeer", 
        b"SuiSeer is a decentralized application (DApp) that brings the ancient art of tarot card reading to the blockchain. Users can engage in tarot card divination and daily draws, receiving personalized insights to guide their lives. A unique feature allows users to mint their tarot reading results and daily cards as NFTs, preserving their experiences as digital collectibles. Leveraging the power of the SUI blockchain, Mystic Indication ensures fast transactions, secure identity management, and a seamless user experience. Join us on this mystical journey and discover the insights that await you!",
        b"https://github.com/Tian-Hun/suiseer",
        b"https://suiseer.walrus.site", 
        b"9cRGwU4YKok1af4EoWlelR8x6c5H9oBs-jh9MotYWGA"
      ],
      // 7
      vector[
        b"NetSepio", 
        b"NetSepio is revolutionizing internet access through the power of DePIN, empowering anyone to set up a VPN node and share their internet bandwidth, thus fostering a network that is both secure and universally accessible. By combining decentralized VPN (dVPN) and decentralized WiFi (dWiFi) technologies, our mission is to make the internet safer, more private, and available to everyone. We achieve this using cutting-edge technologies like zero-knowledge proofs to secure your data, AI-driven tools to detect and respond to threats proactively, and blockchain to ensure transparency and decentralization. Whether you're a business looking to protect your employees and subsidize internet costs for your users or an individual seeking private, high-speed internet, Erebrus offers a versatile and secure solution, transforming the way we experience the digital world.", 
        b"https://github.com/NetSepio/erebrus-frontend", 
        b"", 
        b"2-G8l585sbB_JLMCQlhZWysHyM9b5DVqmGdwf_EgiBg"
      ],
      // 8
      vector[
        b"Tuskscipt", 
        b"TuskScript is a TypeScript-based npm package designed to simplify development on the Walrus network. By providing an intuitive API for seamless data storage and retrieval, TuskScript enables developers to easily integrate decentralized storage solutions into both Web2 and Web3 applications. With built-in support for TypeScript types and flexible data handling, TuskScript bridges the gap between traditional and decentralized data availability, making it easier than ever to build innovative blockchain applications with minimal effort.\n\nIn addition to TuskScript, this project includes a starter kit called create-tusk-app, which helps developers integrate Sui and Walrus into their React applications. What makes this template unique is its ability to convert a React app into a Walrus dApp that can be deployed directly on the Walrus network. For more details, check out the README.md at https://github.com/Sorbin/tusk-dapp?tab=readme-ov-file#deploying-to-walrus  and the live tusk-dapp on Walrus at https://4b90hd5a1rmgzt5bkgq0bcsi2x9rq3u6gmi8ek6vm240spjogd.walrus.site/.\n\nStart integrating Walrus into your dApp with npm i tuskscript, or create a new unique idea on Sui and Walrus with npx create-tusk-app.\n\n- Demo Video BlobID (download as .mp4): X3Uqsqz52OaaNzqjY3_mlQjfHK2yNiIIooRrBvf3I\n- tuskscript NPM: https://www.npmjs.com/package/tuskscript\n- tuskscript Source: https://github.com/Sorbin/tuskscript\n- create-tusk-app NPM: https://www.npmjs.com/package/create-tusk-app\n- create-tusk-app on Walrus: https://4b90hd5a1rmgzt5bkgq0bcsi2x9rq3u6gmi8ek6vm240spjogd.walrus.site/\n\n- create-tusk-app Source: https://github.com/Sorbin/create-tusk-app", 
        b"https://github.com/SovaSniper/tuskscript", 
        b"https://4b90hd5a1rmgzt5bkgq0bcsi2x9rq3u6gmi8ek6vm240spjogd.walrus.site", 
        b"2-X3Uqsqz52OaaNzqjY3_mlQjfHK2yNiIIooRrBvf3I"
      ],
      // 9
      vector[
        b"Vanishr", 
        b"Vanishr aims to provide a secure and private file sharing platform. By leveraging web3 technology and the Walrus storage system, it achieves encrypted file storage and self-destructing functionality.", 
        b"https://github.com/alva-lin/vanishr", 
        b"https://vanishr.walrus.site", 
        b"2bQNFFuHvMu6-wQnPZxFfNBzhUEl64S9FuxOiL-1v8A"
      ],
      // 10
      vector[
        b"WoodenFish", 
        b"Knocking on the cyber woodchuck, accumulating cyber merit.", 
        b"https://github.com/greycodee/merit", 
        b"https://4amcibwhmk4xc89vj79ezkjqzg6kpri088sqm8yrw8mhgehe5r.walrus.site", 
        b"3rzu4_nnyX6MkCt6n0uvCXpNwHj44iAjmTw_AJFr01A"
      ],
      // 11
      vector[
        b"SuieTail", 
        b"‘SuieTail’, powered by AI and blockchain technology, enables creators  to monetize their own AI chatbots, while users are satisfied with in-depth and accurate responses. Using Retrieval-Augmented Generation (RAG), incidences of hallucinations or incorrect outputs are significantly reduced, thereby improving the content’s reliability and richness. With the blockchain reward system, creators are fairly and transparently compensated based on the amount of tokens created for generating responses. We aim to create a virtuous cycle of decentralized AI where creators and users can freely engage with diverse custom AI chatbots.", 
        b"https://github.com/orgs/SuieTail/repositories", 
        b"https://5keknpr1vc05ujgwd0jk4q9kna0jgbergs39plvo2yh3pmkdp0.walrus.site", 
        b"3w2OPHhGbvnj1SzIZFKb66TDsY6ujko0vWJAIiaXd4Y"
      ],
      // 12
      vector[
        b"sui-ai-agents", 
        b"Sui-AI-Agents introduces a cutting-edge decentralized AI agent network that merges AI with web3, aiming to create a permissionless network for AI agents. Utilizing web3, it pioneers an Artificial Intelligence finance system (AiFi), enhancing transparency, security, and efficiency in deploying, operating, and transacting AI services via blockchain. Sui-AI-Agents envisions a future of decentralized intelligent services and financial ecosystems, offering an accessible, reliable platform for developers, businesses, and users to exchange and manage AI services.\n\nThis platform streamlines the operational framework for AI agents, simplifying the process of managing APIs and subscriptions by utilizing Agent services. These services enable agents to autonomously make decisions and take actions without manual API integrations, facilitated by the integration of cryptocurrency transactions within a decentralized AI financial system.\n\nSui-AI-Agents use Walrus to store call agent results, so everything is fully decentralized", 
        b"https://github.com/fantasyni/sui-ai-agents", 
        b"https://2yjupvm8x2yun1ooob9yu7ixkp4a1irk10xnn5sd94ra3dbhva.walrus.site/#/", 
        b"3yEQlCV_2fQ4ZETNNUnLdmv2BPQFi5EpZAVtN-izRTo"
      ],
      // 13
      vector[
        b"Diffend - Divergence Terminator", 
        b"Diffend is a decentralized disagreement finisher used to resolve previous disagreements between people and record them permanently on the blockchain. Users add bets, and the winner wins the bet. Those who participate in the voting also receive a 10% reward.", 
        b"https://github.com/Wujerry/diffend-walrus-sites", 
        b"https://diffend.walrus.site/", 
        b"8OtVO0d5cavTrMxAjZP-VKsjaSu3OUpI6r0HeyKxuP8"
      ],
      // 14
      vector[
        b"Itheum", 
        b"Itheum tokenizes data using the Data NFT standard, which we pioneered, enabling transparent trading of bulk data with AI companies. We currently focus on tokenization of music and gaming data.", 
        b"https://github.com/zedgehorizon/zstorage", 
        b"https://itheumwalrusmusic.walrus.site/", 
        b"9JCY_1fxmT73gY3PWuG4BL9zEe_910EvgGJJ1k7kv1w"
      ],
      // 15
      vector[
        b"DriftBottle", 
        b"Drift bottle on chain：\n- Is there something you've always wanted to say but never found the courage? What are you afraid of? What’s holding you back? Send a drift bottle and release the words that have been weighing on your heart.\n- Is there someone you can't stop thinking about, someone you long to speak to but don’t dare? Write your feelings in a drift bottle, and maybe it will find its way to them.\n- Has anyone ever told you, \"I love you more than anything\"?\n- Feeling overwhelmed? Need a place to let it all out? Write down the burdens on your heart and send them drifting away.\n- Did you know? That year, I waited for you… until the very end. ", 
        b"https://github.com/orgs/DriftBottleOnSui/repositories", 
        b"https://drift-bottle.walrus.site/", 
        b"9sINIHO2nHR0usD8ZBlX1FdqEsmbefwhU1Wc0XhQsmg"
      ],
      // 16
      vector[
        b"Walrus game", 
        b"A little game about walruses, penguins, and fish. Each walrus minted comes with its own site tied to the NFT. Use the walrus to catch fish, the fire to cook the fish, and then buy penguins with cooked fish who will then catch more fish for you. The walrus with the most penguins and fish wins.", 
        b"https://github.com/builders-of-stuff/walrus-game", 
        b"https://27cq3tlycwm5nihei6oxv6pbo2c1z5dpv6y67e7ux6swvwgra8.walrus.site/", 
        b"13syIo0JUrTtS1tgXulsR-JlcTlbwrdmC-6Q7_H-hPg"
      ],
      // 17
      vector[
        b"Walnet", 
        b"Cloud Computing with Blockchain Technology\n\nIn today's fast-changing tech world, more and more people need powerful computers. Walnet is a new solution to this problem. It combines cloud computing with the Sui blockchain to create a strong and safe system for users.\n\nWalnet  let users access powerful computer resources for many different tasks. This combination makes Walnet a useful tool for various computing needs.", 
        b"https://github.com/Weminal-labs/walrus-net-online", 
        b"https://walnet.weminal.com/", 
        b"41bVuxIsY29r_2ILBRsaqyWQEzFQQwd6Lf2h3J77EVw"
      ],
      // 18
      vector[
        b"Suiftly.io", 
        b"CDN optimizations for Sui Walrus. Load most blobs under 100 milliseconds. \n\nMany ways to integrate, including a NPM package for automatic CDN to Walrus failover and blob authentication.\n\nDemo: https://suiftly.walrus.site\n\nVideo: https://cdn.suiftly.io/blob/a4D3emjgYleUSuCuaIu51b6PAEBiC_ddd9dzspovhiU\n\nMore info: https://suiftly.io", 
        b"https://github.com/chainmovers/suiftly", 
        b"https://suiftly.walrus.site", 
        b"a4D3emjgYleUSuCuaIu51b6PAEBiC_ddd9dzspovhiU"
      ],
      // 19
      vector[
        b"Suitok", 
        b"Suitok is a decentralized Web3 platform for video creators, powered by Walrus, that lets users upload, store, and share videos securely using blockchain technology. Future updates will include Sui smart contract integration and new monetization opportunities for creators.", 
        b"https://github.com/suitokdev/suitok", 
        b"https://suitok.walrus.site", 
        b"AC3B-r1gxfQIqmskbkY-BOhZ8OqXkkKHICgfarDZU3A"
      ],
      // 20
      vector[
        b"MvnToWalrus", 
        b"Mvn to walrus is a mvn plugin to upload file to walrus in mvn lifecycle.", 
        b"https://github.com/willser/mvnTowalrus", 
        b"https://maven.walrus.site/", 
        b"ALOQpoCBeDVrT7XureqUw9KIrlu6bLIGiz0vtkvx69Q"
      ],
      // 21
      vector[
        b"FormPilot (aka Crazyforms)", 
        b"Its hard to user feedback & Insights...\n\nDon't worry we make it easy by various suite of tools integrated in one platform also streamline your workflows\n\nHere are the suite of tools -\n\n- Affiliates\n- Escrows\n- Real time rewards\n- LLM summarizer\n- Votings\n- Airdrops\n- Marketplace to discover\n- LLM validator\n- Claim coupon & giveaways\n- Supports multichain\n\nUse cases - \n\n- User signups your platform, where you can send feedback form based on it incentive the user with realtime rewards\n\n- If you want to distribute some giveways - Load your tokens into escrow pools based it users can claim with their wallets accordingly\n\n- You can summarize all the user responses in short paragraph what they think about platform using LLM summarizer\n\n- You can adding list of choices that users can vote and understand their opinions\n\n- You can release form whoever submits will get instant airdrops\n\n- Share form and earn rewards using affiliate program \n\n- (under development) LLM validator validates the responses of the form and based on it, It will distribute the reward accordingly ", 
        b"https://github.com/BalanaguYashwanth/crazyforms", 
        b"https://49ackm64tza2xuj5zl7cbubfez8hxeb6m1klwu02msov8a6dyp.walrus.site/#/", 
        b"WfUUOEeMsTh18r6Jw3m95eIlj6fgn50lsH2pEs3RGlw"
      ],
      // 22
      vector[
        b"Sui-Gallery", 
        b"AI-decentralized art gallery where anyone can be an artist or a collector. How it works: Create your art with the help of AI and mint it as your own. Showcase your art on a stand-alone Walrus Site where interested buyers can bid a price for it.", 
        b"https://github.com/SuiGallery/sui_gallery", 
        b"https://6683buvw2z7jvkg37ufutxtei0beoo45uew8vmr7uxa2vnkhxg.walrus.site/", 
        b"JopvwwiMJPbXnuVesP8KF-Y4GVDVbIwpsCdLoArWgR8"
      ],
      // 23
      vector[
        b"Sui Liquidity", 
        b"The flow cell function developed on sui is mainly used to learn the operating principle of the flow cell and simulate the situation inside the flow cell.", 
        b"https://github.com/1pzq/sui_DApp.git", 
        b"https://1pzqy.walrus.site/", 
        b"bMP5EjLMJVF37TMH7WohRWxYZtBuxsZr1k7MK46ehHM"
      ],
      // 24
      vector[
        b"Doomsday Protocol: Rebirth in Another World", 
        b"A strategic card battle game featuring an AI agent built with Sui's latest random modules, seamlessly integrated with Walrus for static content storage.", 
        b"https://github.com/xiaodi007/AI-CardGame", 
        b"https://xq917z4n9e1acc9lljw6lhopnjigg0xdu971sb07w0pdrs8rs.walrus.site/", 
        b"DiGYqS9SVCvlyIVgP22LhxVBPcY5ECCtiNqCugYPjAc"
      ],
      // 25
      vector[
        b"SuiSurvey", 
        b"On-chain survey/polling/voting. Ensured privacy, data safety, security and ease of reward distribution. ", 
        b"https://github.com/sui-survey/suisurvey", 
        b"https://sui-survey.walrus.site/", 
        b"dnDfByrKBxWjRJhaILljLcUEASw9GpT2cgURDXuxjGo"
      ],
      // 26
      vector[
        b"Inazuma", 
        b"Decentralized indexer for asset monitoring and event-triggered recording, offering real-time tracking of account changes and key events.", 
        b"https://github.com/chitaolang/inazuma", 
        b"https://inazuma.walrus.site/", 
        b"enBXkl7xjgDFfyevDulzGr__XTzVgyy5grMYVWtM-bQ"
      ],
      // 27
      vector[
        b"CRE8SPACE", 
        b"Cre8Space is a decentralized platform that empowers content creators to retain full ownership of their content, offering transparent and fair monetization opportunities through blockchain technology. The platform decentralizes used Walrus for content storage and management, giving creators a direct avenue for monetizing their work, collaborating with peers, and engaging their audience with transparency. Creators have direct ownership of the content they store in the platform. Powered by Sui blockchain technology and Walrus, Cre8Space provides an ecosystem that supports content authenticity, discoverability, and incentivization.", 
        b"https://github.com/ibriz/cre8Space", 
        b"https://cre8space.walrus.site/", 
        b"gKNGmwkwXwepY9ZbJJw5VhfMZ8irBQ81evx4cYL1woA"
      ],
      // 28
      vector[
        b"Suipet", 
        b"This is a growth-oriented pet that will level up as you answer questions and check in. You can change the appearance of the pet.", 
        b"https://github.com/gonahot", 
        b"https://ppcrgfwi58d6m81yobkipe37uvcr50w5ouuasm14livks9not.walrus.site", 
        b"gpS7ldWithDwN2Tt4FMe7W5mM0h_2jP9lCtIERHGbBo"
      ],
      // 29
      vector[
        b"SuiS3", 
        b"Walrus provides efficient and robust decentralized storage. Basically it maintains a mapping from blob id to content, i.e. a flat namespace structure. The flat storage model presents challenges in terms of human usability and management. \nSuiS3 is a tool that presents an AWS S3-style CLI, facilitating the effective management of Walrus' flat data storage in a structured and meaningful hierarchy, through the related metadata stored on Sui.", 
        b"https://github.com/siphonelee/SuiS3", 
        b"https://3k72mblg9csrgajc53ijbsq6ia2fwebliz5984j5h2p15axdxw.walrus.site", 
        b"GqU497wZUty12Jou_bUFb9FdGg3xYsh85fzcCkUimJw"
      ],
      // 30
      vector[
        b"Loonah", 
        b"Loonah empowers users by providing a fully decentralized platform for hosting static websites (React, vue) on walrus and abstracting any need for extra hassle, just connect your github to loonah using oauth and select a repo, sit back and let loonah do the rest.", 
        b"https://github.com/loonah-app", 
        b"https://www.loonah.xyz", 
        b"H9NPh1yDhe9nwLaNuwmZl0Jy2MSAa7Ft_r21u8dNpn0"
      ],
      // 31
      vector[
        b"Orai3D The Evolution of 3d Design Tools", 
        b"Orai3D is an innovative platform that offers a dynamic environment for designing and collaborating on decentralized 3D assets. Orai3D simplifies the process of designing and minting NFTs by integrating AI-generated images and user interaction through Weminal's assistance. The platform securely stores the generated images on Eueno's decentralized storage.\n\nWe encourages users to share their creations with other artists", 
        b"https://github.com/Weminal-labs/walrus-3d", 
        b"https://orai3d.walrus.site/", 
        b"HQuAfVwwPx_FSF4H6VinGkhDcZiRYkTAtW21kqwMB-g"
      ],
      // 33
      vector[
        b"Cyferio", 
        b"Cyferio is a Trustless Modular Calculator (TMC), a modular co-processor, and a Rollup Stack that enables verifiable FHE. TMC unlocks privacy-preserving, massively parallel execution of computations for both Web2 and Web3 applications.", 
        b"https://github.com/cyferio-labs", 
        b"https://1pxivrs1ha2w8dpv4nzx3sxkic9oplah23jqcrgfmrckq29k9q.walrus.site", 
        b"j_syZ8Lwx7nMYmcFZkU0B60RRF8jm3KcWRtjrsnJ1VM"
      ],
      // 34
      vector[
        b"Walrus Sites GA", 
        b"Using GitHub Actions to deploy a Walrus website provides an automated workflow that allows automatic deployment with each code change, eliminating the need to worry about Walrus CLI configurations. In addition, GitHub simplifies version control and history tracking, providing clear proof of origin for each deployment, increasing reliability and transparency.", 
        b"https://github.com/zktx-io/walrus-sites-ga", 
        b"https://github.com/marketplace/actions/walrus-sites-ga", 
        b"JSQ-xt7E7KNSKgiAL3IBT5B5_3Hk_ZMiMZFHGqynkYU"
      ],
      // 35
      vector[
        b"sui write3", 
        b"A platform for novel authors to upload novels", 
        b"https://github.com/etboodXJ/SuiWrite3.git", 
        b"https://2y9gbik28yu65mv8te77tiolcv7b2f3z7m5365p3y066wrj5sn.walrus.site", 
        b"KwrwvGCaFsbUR9zQVRP5Khn2YwxfYcQth0JQRcY4B3c"
      ],
      // 36
      vector[
        b"GachaGame_SUI", 
        b"A gashapon machine game on the sui chain. Although it is very simple, I hope you can have fun.", 
        b"https://github.com/StarryDeserts/GachaGame_SUI", 
        b"https://starrydesert.walrus.site/", 
        b"Lg2wWxtnESiqYBOfEgmuM-7qpHYiMG7IvPs990s1ghM"
      ],
      // 37
      vector[
        b"JarJar FileStorage", 
        b"Fully decentralized user friendly file storage solution that can store on Walrus or directly on SUI blockchain\n\nX: @JARJARxyz", 
        b"https://github.com/orgs/jarjar-xyz/repositories", 
        b"https://19mxww1lum74y3yg9o26rxtu2i5pvxq6ff66cz88v4nqi3kw3p.walrus.site/", 
        b"muE11mnnLvstleoL4az8h0Y_psuY88CaENoNi0W1N8o"
      ],
      // 38
      vector[
        b"SurgeBuzz", 
        b"web3 decentralized social platform", 
        b"https://github.com/AricRedemption/surge-buzz", 
        b"https://40z9unilx75qdvpqh9jfc5g6ukqcg00cqho5ch7isn0r5lh0kv.walrus.site/", 
        b"mvYCF3ESQgrI99pJV10NTC3ONF328wRx81bQ6fMGiqY"
      ],
      // 39
      vector[
        b"SecretLink", 
        b"SecretLink\nWalrus Protocol-based encrypted storage facilities allow us to manage users' encrypted data in a faster and more manageable manner\n\n\nFeature:\n1. End-to-End Encryption\nYour data is encrypted before it leaves your device.\n\n2. Immutable Records\nSui Blockchain And Walrus Protocol ensures your shared content remains tamper-proof and verifiable.\n\n3. Decentralized Security\nNo single point of failure. Your data is distributed across the network.\n\n\nHow SecretLink Works\n1. Upload Content\nUpload your file or enter text to be encrypted.\n\n2. Generate Encryption Key\nA unique encryption key is generated in your browser.\n\n3. Encrypt Data\nYour content is encrypted using AES encryption.\n\n4. Store Encrypted Data\nEncrypted data is stored in SUI Walrus distributed storage.\n\n5. Generate Shareable Link\nA unique link is created for accessing the encrypted content.", 
        b"https://github.com/Euraxluo/secretlink", 
        b"https://secretlink.walrus.site/", 
        b"oBFdZsNSQcQFwcHLaEL5Ar5LdbcB6Qw3qMTpiYKxDEI"
      ],
      // 40
      vector[
        b"Vehicle-Lifetime", 
        b"Vehicle-Lifetime is a Sui dApp that allows users to track the lifetime of their vehicles. It provides a platform for users to record and monitor various aspects of their vehicle's usage, maintenance, and performance.", 
        b"https://github.com/fantasy-move/vehicle-lifetime", 
        b"https://vehicle-lifetime.walrus.site/", 
        b"OhQaqG9cJHqq4TluwAprVfzR9BO9XOR16J2x6AgCfM8"
      ],
      // 41
      vector[
        b"Simple PKI prototype with Walrus", 
        b"Actual PKI or CA is mostly used for communications between users and companies. It involves with HTTPS, DNSSEC, and secure software installation. While users and users can still communicate by using certificates created from custom PKI/CA, it will be overkill, complicated and high costs if the communications were changed from users and companies into users and users. This prototype will be creating a simple CA that can be used specifically for small scale user to user communication. ", 
        b"https://github.com/Chewhern/Walrus_HApp", 
        b"https://dspkiproto.walrus.site/", 
        b"OqZ2CJnV1RmZ_9kQv2I7GK5AL_dlZfs1fgyupcahtpc"
      ],
      // 42
      vector[
        b"Typing Hero Game", 
        b"A typing speed competition game\n\nPlayers can upload articles themselves or directly use articles uploaded by other players to compete in typing speed\n\nThese articles are stored on Walrus with blob IDs stored in the contract\n\nAfter typing a result prompt will be generated indicating the accuracy number of errors and speed using WPM(Words per Minute) for speed\n\nPlayers can upload their own results and the fastest player will be displayed on the homepage",
        b"https://github.com/bityoume/typing_hero_sui_walrus_game", 
        b"https://typinghero.walrus.site/", 
        b"pU-4CedtO9x7Xsk2qV8Ehjh5009NKW9IKCxSMBU1-SA"
      ],
      // 43
      vector[
        b"Walrus Share", 
        b"Walrus Share is a file sharing app based on the Walrus protocol. Walrus Share app can not only provide Walrus-based distributed storage, but also verify the sharing permissions of files. This ensures that the original file owner can gain benefits from file sharing.\n\nThe Walrus Share application uses javascript running within your web browser to encrypt and decrypt files client-side, in-browser. All client-side cryptography is implemented using the Web Crypto API. Files are encrypted using AES-CBC 256-bit symmetric encryption. The encryption key is derived from the password and a random salt using PBKDF2 derivation with 10000 iterations of SHA256 hashing.\n\nWalrus Share application provides three ways to share files: free, verification code and paid.\n\nUse free: When the user visits the URL you provided, they can view the pictures you shared for free.\n\nUse verification code: When the user visits the URL you provided, they will need to enter the verification code you provided to view the pictures you shared.\n\nUse pay: When the user visits the URL you provided, the user needs to connect to his wallet and pay SUI coins according to the fee you set. After the payment is successful, he can view the pictures you shared.\n\nBecause the developers of Walrus Share need to continuously maintain the updates and use of the system, user need to pay 1 Sui Coin when using Walrus Share to encrypt and share files.", 
        b"https://github.com/croal99/walrus-share.git", 
        b"https://5qfz5r7xy7nn2dfk9v6kbknizkwy2yxeqpgplxk84sv83fc1ox.walrus.site", 
        b"pUtWTEIBJRt6MVCDcKaVcEYjqO7WFXvc3-Ne5h2k45k"
      ],
      // 44
      vector[
        b"Walrus Registry", 
        b"The first web 3.0 OCI/docker container registry.\n\nYou can use this to pull and push docker container images and other OCI compliant images.\n\nI'm going to extend this with a better serialization algorithm to store multiple OCI layers in one blob for better walrus performance.\n\nThat way it can be extended to store other data like S3, or scientific data(like ASDF).\n\nI would also like to convert parts of this to an extension for the most popular CloudNative container registry.", 
        b"https://github.com/fishman/walrus-registry", 
        b"https://2higmixns8zh5g0lkv3iosy8p9amz68virmthxvfchw5d2z6x.walrus.site/", 
        b"qh5KXOa2nMoDStugGvXHhJJv4NCGQsPj-kCHtnN_QwA"
      ],
      // 45
      vector[
        b"BlobSee", 
        b"Walrus Sites file manager. 100% client-side media/files navigator with optional client-side AES encryption, solid caching and a lot of fun and huge respect for blobs.", 
        b"https://github.com/suidouble/blobsee", 
        b"https://blobsee.walrus.site/", 
        b"QpNwixUTSr7DpUaAGmzKob8c6DROKiu0oz7tPFSKqXQ"
      ],
      // 46
      vector[
        b"SuiPump:Token Market", 
        b"SuiPump: Token Market project was inspired by PumpFun. Since PumpFun is a token trading market on the Solana blockchain, we wanted to implement similar functionality on the Sui blockchain. We modeled the frontend layout after PumpFun and used React, Vue3, and Vite as our frontend technology stack, with Go as the backend API architecture. We built a system on the SuiPump website that enables token creation, trading, and other functionalities. Token trading is controlled by a bonding curve, where the token price increases as more people purchase it. The frontend is fully deployed on Walrus, with most functionalities implemented on the frontend, except for some information retrieved via API requests.\n\nThe reason for using the API is that when a user creates a coin, we generate a new address for that coin to facilitate trading. To complete functions like address creation, contract deployment, and information entry, we deal with dynamic data that is difficult to associate through Walrus alone, so we also store this information in a MySQL database to prevent data loss during testing. While the main page and the display of user-created coins are handled by reading backend information, all other coin information displays are achieved by executing queries and commands directly on the frontend.\n\nDue to limitations in team size and technical expertise, I encountered many issues, particularly with communication between the frontend and my own server. Since this was my first time working on such a large project, and I was learning as I went along, there are still some unresolved stability issues. On the Walrus site, sometimes the entire process works smoothly, while at other times, bugs occur. However, overall, the project successfully implements trading functionalities and visualizes trading information. \n\nThis has been a journey of learning and implementing Sui Move from 0 to 1, and I hope to continue improving in the future. I sincerely welcome your feedback and suggestions! Thank you!", 
        b"https://github.com/Ocrand/SuiPump-Token-Market", 
        b"https://suipump.walrus.site/", 
        b"r3lwCdv6CCAkMCs63Ol2DSeHqNF-Rjan07h8TspOXHs"
      ],
      // 47
      vector[
        b"LinkForge", 
        b"An SBT that connects people, working with walrus", 
        b"https://github.com/Euraxluo/linkforge", 
        b"https://linkforge.walrus.site", 
        b"SpxDM37bkaF_fR8dDkPCHl4hGusvsDQBIzCu2myCn9w"
      ],
      // 48
      vector[
        b"Walrus Pass", 
        b"Walrus Pass is an innovative solution designed to securely manage and verify digital assets such as subscription models, proof of purchase, concert tickets, licenses, and more. Leveraging the security and transparency of blockchain technology, Walrus Pass enables users to effectively prove their rights to various assets.", 
        b"https://github.com/zktx-io/walrus-pass-monorepo", 
        b"https://docs.zktx.io/walrus/walrus-pass.html", 
        b"tafMqHCbsQZ99sofKgsOI1dHxepBvOlq1PmR-Oy9hrA"
      ],
      // 49
      vector[
        b"Lotan", 
        b"an open-source protocol with very friendly interface to help builders, users to interact with the game-changer in SUI's NFT technology - Walrus", 
        b"https://github.com/lotan-app/lotan-monorepo", 
        b"https://lotan.app/", 
        b"tTj3aq3IW6HFAgbQv-I8KrAigT1M46vLnV18amklHY8"
      ],
      // 50
      vector[
        b"Walcast", 
        b"An open-source kit to optimize your developer workflow. ", 
        b"https://github.com/Weminal-labs/walrus-raycast", 
        b"https://walcast.walrus.site", 
        b"TWBkPHwrxMdDJkELpApslGZTRGCFSdO6YEvkm0mgKPE"
      ],
      // 51
      vector[
        b"Sui Jump", 
        b"A game relying on walrus decentralized storage.", 
        b"https://github.com/djytwy/Sui_jump", 
        b"https://1vhr1c50tul218ayp0b1dif7e1lrcx1tmu58o97lp8u04m034z.walrus.site", 
        b"U5CjLKjN_jSmpzBpQiqi7-DwLRhTDXfng5FsM_LMky4"
      ],
      // 52
      vector[
        b"Cable", 
        b"Cable is an end-to-end encrypted wallet-to-wallet messaging app, powered by Walrus.", 
        b"https://github.com/ronanyeah/cable", 
        b"https://cable.walrus.site/", 
        b"uoHoCrVmGhMe-zCSs0qnsZA6LlArYFJX0i9kjdiJvhg"
      ],
      // 53
      vector[
        b"Walrus Disk", 
        b"Welcome to the Walrus Disk, a decentralized storage application that uses the Walrus protocol to store encrypted files. Walrus protocol focuses on providing a robust but affordable solution for storing unstructured content on decentralized storage nodes while ensuring high availability and reliability even in the presence of Byzantine faults.\n\nThe Walrus Disk application uses javascript running within your web browser to encrypt and decrypt files client-side, in-browser. Walrus Disk makes no network connections during this process, to ensure that your keys never leave the web browser during the process.\n\nThe Walrus Disk application stored the encrypted files in the Walrus system and the keys in the locally, thus ensuring the security of the files. When you need these files, the Walrus Disk application can easily use the Walrus protocol to download the encrypted files and then decrypt them with the local key.\n\nAll client-side cryptography is implemented using the Web Crypto API. Files are encrypted using AES-CBC 256-bit symmetric encryption. The encryption key is derived from the password and a random salt using PBKDF2 derivation with 10000 iterations of SHA256 hashing.\n\nYou can visit the demo in https://3le187byarbjhebojrko3ifez30klgqqol680rxspl5l5orchr.walrus.site ", 
        b"https://github.com/croal99/walrus-disk.git", 
        b"https://3le187byarbjhebojrko3ifez30klgqqol680rxspl5l5orchr.walrus.site", 
        b"vGUTk7xNAxPc3BkkNMfIQYyf91RoXibHKfOuEXoc58o"
      ],
      // 54
      vector[
        b"Sui Meet", 
        b"web3 matching site. Meet your significant other, friend with common interests, or simply make meaningful connections", 
        b"https://github.com/orgs/Sui-Meet/repositories", 
        b"https://sui-meet.walrus.site/", 
        b"VlV67jggAlJQbHPybKp4pButStXjkuDbBcqHotZ901U"
      ],
      // 55
      vector[
        b"Walrus NFT Generator", 
        b"The Walrus NFT Generator is  website that allows you to create unique, multi-layered NFTs by combining your uploaded images using our unique algorithm. All images and NFTs are securely stored on Walrus, providing decentralized and secure data storage to ensure your digital artifacts are protected and accessible at any time.", 
        b"https://github.com/TanyDev-pro/gen-nft-sui", 
        b"https://gen-nft.walrus.site/", 
        b"Vzt3Raos9U8jkOr8nKgE2EYunhEMSXxfrbtKneiET2Y"
      ],
      // 56
      vector[
        b"de-docker-hub", 
        b"Decentralized Docker Hub, store the Docker image in walrus", 
        b"https://github.com/rickiey/de-docker-hub-walrus", 
        b"https://wuea98mxtzewdatthsgqpxtf7z2bb0c8pigoof3sx08gkg1s4.walrus.site", 
        b"w_67oW9UyS4JSUnegIJarPiNQWZGWevUkVHFcI9zyTc"
      ],
      // 57
      vector[
        b"IceArrow", 
        b"A secure way to share secrets online. It's a hybrid web app and a browser extension. Encrypted secret messages and files are stored on Walrus as well as the app frontend.", 
        b"https://github.com/kkomelin/icearrow", 
        b"https://icearrow.xyz", 
        b"WDo0YRepgWRQP58v8HjKlBsBT8ihA2JytOb3tM-r7tA"
      ],
      // 58
      vector[
        b"Walrus Site Uploader", 
        b"A simple and user-friendly tool to help deploy webpages to Walrus.\n\nWe plan to add more useful management features, such as managing webpages within accounts, deleting or adding pages, and renewing subscriptions.", 
        b"https://github.com/Isatis-labs/walrus-site-uploader", 
        b"https://walrus-site-uploader.walrus.site/", 
        b"Yn20KZtd8TmCg1ssovnhzC7Kv6xtTRnIEij9UZOabCU"
      ],
      // 59
      vector[
        b"WalrusFS", 
        b"Imagine a decentralized file system, like a windows operating system. When I upload a file to walrus, the system can display a file and point to a blob_id. I can easily download the file stored in walrus by clicking on the file, and then do more", 
        b"https://github.com/applesline/WalrusFS.git", 
        b"https://walrusfs.walrus.site", 
        b"YNX24gx52994yIHE8cb03hfM0tfcpuC1rFxoS1WemTY"
      ],
      // 60
      vector[
        b"Walrus Wayback", 
        b"Walrus Wayback Machine is an innovative tool that enables users to permanently archive and restore websites using Walrus. It preserves websites in their original form, making them accessible and unaltered for future generations as part of our shared digital heritage.", 
        b"https://github.com/umbrelchee/wayback.walrus.site", 
        b"https://wayback.walrus.site", 
        b"ZS79fNgnAAMTedEN-fvZMhecg4W69o8mt5W71Q1zyj0"
      ],
      // 61
      vector[
        b"BlobVault", 
        b"BlobVault is a secure file encryption and decryption platform that allows users to encrypt files, upload them to the Walrus system, and later decrypt and retrieve them using a secret key and Blob ID - In the future this platform will turn into a decentralized emailing service.", 
        b"https://github.com/FudDeath/BlobVault", 
        b"https://encrypt.walrus.site/", 
        b"ZvexreFjRKcpF9HQlf4GoxD9wkQr7ORcKm8xZaqp-5U"
      ],
    ];

    let mut project_list = table::new(ctx);

    let mut index = 0;

    while (index < projects.length()) {
      project_list.add(index, Project {
        id: index, 
        votes: 0, 
        name: projects[index][0].to_string(), 
        description: projects[index][1].to_string(), 
        github_url: url::new_unsafe(projects[index][2].to_ascii_string()), 
        walrus_site_url: url::new_unsafe(projects[index][3].to_ascii_string()), 
        video_blob_id: projects[index][4].to_string()
      });

      // address::from_bytes(projects[index][5]);

      index = index + 1;
    };

    let votes = Votes {
      id: object::new(ctx),
      total_votes: 0, 
      project_list,
      ballots: table::new(ctx),
      voting_active: false,
      whitelist_tokens: vec_set::empty()
    };
    transfer::share_object(votes);

    transfer::transfer(
      AdminCap {
        id: object::new(ctx)
      }, 
      ctx.sender()
    );
  }
  
  public fun vote(project_ids: vector<u64>, votes: &mut Votes, address_seed: u256, ctx: &TxContext) {
    let voter = ctx.sender();

    assert_user_has_not_voted(voter, votes);
    assert_sender_zklogin(address_seed, ctx);
    assert_valid_project_ids(project_ids, votes);
    assert_voting_is_active(votes);

    // Update project's vote
    vote_internal(votes, project_ids, ctx);

    // Record user's vote
    table::add(
      &mut votes.ballots, 
      voter, 
      project_ids
    );
  }

  public(package) fun vote_internal(votes: &mut Votes, ballot: vector<u64>, ctx: &TxContext) {
    let voter = ctx.sender();
    let already_voted = votes.ballots.contains(voter);
    // Clean up old ballot
    if (already_voted) {
      let og_ballot = votes.ballots[voter];
      og_ballot.do!(|v| {
        let p = &mut votes.project_list[v];
        p.votes = p.votes - 1;
        votes.total_votes = votes.total_votes - 1;
      });
      votes.ballots.remove(voter);
    };
    // add new ballot
    votes.ballots.add(voter, ballot);
    ballot.do!(|v| {
      let p = &mut votes.project_list[v];
      p.votes = p.votes + 1;
      votes.total_votes = votes.total_votes + 1;
    });
  }

  public entry fun toggle_voting(_: &AdminCap, can_vote: bool, votes: &mut Votes) {
    votes.voting_active = can_vote;
  }

  public(package) fun assert_token_in_whitelist<T>(_: &T, votes: &Votes) {
    let tn = type_name::get<T>();
    assert!(
      votes.whitelist_tokens.contains(&tn), 
      ENotInWhitelist
    );
  }

  fun assert_user_has_not_voted(user: address, votes: &Votes) {
    assert!(
      table::contains(
        &votes.ballots, 
        user
      ) == false, 
      EUserAlreadyVoted
    );
  }

  public(package) fun assert_valid_project_ids(project_ids: vector<u64>, votes: &Votes) {
    let mut ids = vec_map::empty();
    project_ids.do!(|id| {
      assert!(
          votes.project_list.contains(id),
          EInvalidProjectId
      );
      vec_map::insert(&mut ids, id, 0); // this will abort if there is a dup
    });
  }

  public(package) fun assert_voting_is_active(votes: &Votes) {
    assert!(
      votes.voting_active, 
      EVotingInactive
    );
  }

  fun assert_sender_zklogin(address_seed: u256, ctx: &TxContext) {
    let sender = ctx.sender();
    let issuer = string::utf8(b"https://accounts.google.com");
    assert!(check_zklogin_issuer(sender, address_seed, &issuer), EInvalidProof);
  }

  #[test_only]
  public fun init_for_test(ctx: &mut TxContext) {
    init(ctx);
  }
}
