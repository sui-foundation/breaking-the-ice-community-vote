
/// Module: voting
module voting::voting {
  use std::string;
  use sui::table;
  use sui::vec_map;
  use sui::url;
  use sui::zklogin_verified_issuer::check_zklogin_issuer;

  const EInvalidProof: u64 = 1;
  const EUserAlreadyVoted: u64 = 2;
  const ETooManyVotes: u64 = 3;
  const EInvalidProjectId: u64 = 4;
  const EVotingInactive: u64 = 5;

  public struct Votes has key {
    id: UID, 
    total_votes: u64, 
    project_list: vector<Project>,
    votes: table::Table<address, vector<u64>>,
    voting_active: bool
  }

  public struct Project has store {
    id: u64,
    name: string::String, 
    description: string::String, 
    video_blob_id: string::String, 
    walrus_site_url: url::Url, 
    github_url: url::Url,
    votes: u64
  }

  public struct AdminCap has key, store {
    id: UID
  }

  fun init(ctx: &mut TxContext) {

    let projects = vector[
      vector[
        b"WalrusFS", 
        b"Imagine a decentralized file system, like a windows operating system. When I upload a file to walrus, the system can display a file and point to a blob_id. I can easily download the file stored in walrus by clicking on the file, and then do more", 
        b"https://github.com/applesline/WalrusFS.git", 
        b"https://walrusfs.walrus.site", 
        b"YNX24gx52994yIHE8cb03hfM0tfcpuC1rFxoS1WemTY"
      ],
      vector[
        b"Walrus Site Uploader", 
        b"A simple and user-friendly tool to help deploy webpages to Walrus.\n\nWe plan to add more useful management features, such as managing webpages within accounts, deleting or adding pages, and renewing subscriptions.", 
        b"https://github.com/Isatis-labs/walrus-site-uploader", 
        b"https://walrus-site-uploader.walrus.site/", 
        b"Yn20KZtd8TmCg1ssovnhzC7Kv6xtTRnIEij9UZOabCU"
      ],
      vector[
        b"IceArrow", 
        b"A secure way to share secrets online. It's a hybrid web app and a browser extension. Encrypted secret messages and files are stored on Walrus as well as the app frontend.", 
        b"https://github.com/kkomelin/icearrow", 
        b"https://icearrow.xyz", 
        b"WDo0YRepgWRQP58v8HjKlBsBT8ihA2JytOb3tM-r7tA"
      ],
      vector[
        b"de-docker-hub", 
        b"Decentralized Docker Hub, store the Docker image in walrus", 
        b"https://github.com/rickiey/de-docker-hub-walrus", 
        b"https://wuea98mxtzewdatthsgqpxtf7z2bb0c8pigoof3sx08gkg1s4.walrus.site", 
        b"w_67oW9UyS4JSUnegIJarPiNQWZGWevUkVHFcI9zyTc"
      ],
      vector[
        b"Walrus Disk", 
        b"Welcome to the Walrus Disk, a decentralized storage application that uses the Walrus protocol to store encrypted files. Walrus protocol focuses on providing a robust but affordable solution for storing unstructured content on decentralized storage nodes while ensuring high availability and reliability even in the presence of Byzantine faults.\n\nThe Walrus Disk application uses javascript running within your web browser to encrypt and decrypt files client-side, in-browser. Walrus Disk makes no network connections during this process, to ensure that your keys never leave the web browser during the process.\n\nThe Walrus Disk application stored the encrypted files in the Walrus system and the keys in the locally, thus ensuring the security of the files. When you need these files, the Walrus Disk application can easily use the Walrus protocol to download the encrypted files and then decrypt them with the local key.\n\nAll client-side cryptography is implemented using the Web Crypto API. Files are encrypted using AES-CBC 256-bit symmetric encryption. The encryption key is derived from the password and a random salt using PBKDF2 derivation with 10000 iterations of SHA256 hashing.\n\nYou can visit the demo in https://3le187byarbjhebojrko3ifez30klgqqol680rxspl5l5orchr.walrus.site", 
        b"https://github.com/croal99/walrus-disk.git", 
        b"https://3le187byarbjhebojrko3ifez30klgqqol680rxspl5l5orchr.walrus.site", 
        b"vGUTk7xNAxPc3BkkNMfIQYyf91RoXibHKfOuEXoc58o"
      ],
      vector[
        b"Sui Jump", 
        b"A game relying on walrus decentralized storage.", 
        b"https://github.com/djytwy/Sui_jump", 
        b"https://1vhr1c50tul218ayp0b1dif7e1lrcx1tmu58o97lp8u04m034z.walrus.site", 
        b"U5CjLKjN_jSmpzBpQiqi7-DwLRhTDXfng5FsM_LMky4"
      ],
      vector[
        b"Walrus Pass", 
        b"Walrus Pass is an innovative solution designed to securely manage and verify digital assets such as subscription models, proof of purchase, concert tickets, licenses, and more. Leveraging the security and transparency of blockchain technology, Walrus Pass enables users to effectively prove their rights to various assets.", 
        b"https://github.com/zktx-io/walrus-pass-monorepo", 
        b"https://docs.zktx.io/walrus/walrus-pass.html", 
        b"tafMqHCbsQZ99sofKgsOI1dHxepBvOlq1PmR-Oy9hrA"
      ],
      vector[
        b"BlobSee", 
        b"Web Walrus Sites File Manager. Media/files navigator with optional AES encryption, a lot of fun and huge respect for blobs.", 
        b"https://github.com/suidouble/blobsee", 
        b"https://blobsee.walrus.site/", 
        b"QpNwixUTSr7DpUaAGmzKob8c6DROKiu0oz7tPFSKqXQ"
      ],
      vector[
        b"Walrus Share", 
        b"Walrus Share is a file sharing app based on the Walrus protocol. Walrus Share app can not only provide Walrus-based distributed storage, but also verify the sharing permissions of files. This ensures that the original file owner can gain benefits from file sharing.\n\nThe Walrus Share application uses javascript running within your web browser to encrypt and decrypt files client-side, in-browser. All client-side cryptography is implemented using the Web Crypto API. Files are encrypted using AES-CBC 256-bit symmetric encryption. The encryption key is derived from the password and a random salt using PBKDF2 derivation with 10000 iterations of SHA256 hashing.\n\nWalrus Share application provides three ways to share files: free, verification code and paid.\n\nUse free: When the user visits the URL you provided, they can view the pictures you shared for free.\n\nUse verification code: When the user visits the URL you provided, they will need to enter the verification code you provided to view the pictures you shared.\n\nUse pay: When the user visits the URL you provided, the user needs to connect to his wallet and pay SUI coins according to the fee you set. After the payment is successful, he can view the pictures you shared.\n\nBecause the developers of Walrus Share need to continuously maintain the updates and use of the system, user need to pay 1 Sui Coin when using Walrus Share to encrypt and share files.", 
        b"https://github.com/croal99/walrus-share.git", 
        b"https://5qfz5r7xy7nn2dfk9v6kbknizkwy2yxeqpgplxk84sv83fc1ox.walrus.site", 
        b"pUtWTEIBJRt6MVCDcKaVcEYjqO7WFXvc3-Ne5h2k45k"
      ],
      vector[
        b"Typing Hero Game", 
        b"A typing speed competition game. \n\nPlayers can upload articles themselves or directly use articles uploaded by other players to compete in typing speed\n\nThese articles are stored on Walrus, with blob IDs stored in the contract. \n\nAfter typing, a result prompt will be generated indicating the accuracy, number of errors, and speed, using WPM(Words per Minus) for speed. \n\nPlayers can upload their own results, and the fastest player will be displayed on the homepage.", 
        b"https://github.com/bityoume/typing_hero_sui_walrus_game", 
        b"https://typinghero.walrus.site/", 
        b"pU-4CedtO9x7Xsk2qV8Ehjh5009NKW9IKCxSMBU1-SA"
      ],
      vector[
        b"Simple PKI prototype with Walrus", 
        b"Actual PKI or CA is mostly used for communications between users and companies. It involves with HTTPS, DNSSEC, and secure software installation. While users and users can still communicate by using certificates created from custom PKI/CA, it will be overkill, complicated and high costs if the communications were changed from users and companies into users and users. This prototype will be creating a simple CA that can be used specifically for small scale user to user communication. ", 
        b"https://github.com/Chewhern/Walrus_HApp", 
        b"https://dspkiproto.walrus.site/", 
        b"OqZ2CJnV1RmZ_9kQv2I7GK5AL_dlZfs1fgyupcahtpc"
      ],
      vector[
        b"JarJar FileStorage", 
        b"Fully decentralized user friendly file storage solution that can store on Walrus or directly on SUI blockchain\n\nX: @JARJARxyz", 
        b"https://github.com/orgs/jarjar-xyz/repositories", 
        b"https://19mxww1lum74y3yg9o26rxtu2i5pvxq6ff66cz88v4nqi3kw3p.walrus.site/", 
        b"muE11mnnLvstleoL4az8h0Y_psuY88CaENoNi0W1N8o"
      ],
      vector[
        b"Walrus Sites GA", 
        b"Using GitHub Actions to deploy a Walrus website provides an automated workflow that allows automatic deployment with each code change, eliminating the need to worry about Walrus CLI configurations. In addition, GitHub simplifies version control and history tracking, providing clear proof of origin for each deployment, increasing reliability and transparency.", 
        b"https://github.com/zktx-io/walrus-sites-ga", 
        b"https://github.com/marketplace/actions/walrus-sites-ga", 
        b"JSQ-xt7E7KNSKgiAL3IBT5B5_3Hk_ZMiMZFHGqynkYU"
      ],
      vector[
        b"Cyferio", 
        b"Cyferio is a Trustless Modular Calculator (TMC), a modular co-processor, and a Rollup Stack that enables verifiable FHE. TMC unlocks privacy-preserving, massively parallel execution of computations for both Web2 and Web3 applications.", 
        b"https://github.com/cyferio-labs", 
        b"https://1pxivrs1ha2w8dpv4nzx3sxkic9oplah23jqcrgfmrckq29k9q.walrus.site", 
        b"j_syZ8Lwx7nMYmcFZkU0B60RRF8jm3KcWRtjrsnJ1VM"
      ],
      vector[
        b"Suipet", 
        b"This is a growth-oriented pet that will level up as you answer questions and check in. You can change the appearance of the pet.", 
        b"https://github.com/gonahot", 
        b"https://ppcrgfwi58d6m81yobkipe37uvcr50w5ouuasm14livks9not.walrus.site", 
        b"gpS7ldWithDwN2Tt4FMe7W5mM0h_2jP9lCtIERHGbBo"
      ],
      vector[
        b"CRE8SPACE", 
        b"Cre8Space is a decentralized platform that empowers content creators to retain full ownership of their content, offering transparent and fair monetization opportunities through blockchain technology. The platform decentralizes used Walrus for content storage and management, giving creators a direct avenue for monetizing their work, collaborating with peers, and engaging their audience with transparency. Creators have direct ownership of the content they store in the platform. Powered by Sui blockchain technology and Walrus, Cre8Space provides an ecosystem that supports content authenticity, discoverability, and incentivization.", 
        b"https://github.com/ibriz/cre8Space", 
        b"https://cre8space.walrus.site/", 
        b"gKNGmwkwXwepY9ZbJJw5VhfMZ8irBQ81evx4cYL1woA"
      ],
      vector[
        b"Doomsday Protocol: Rebirth in Another World", 
        b"A strategic card battle game featuring an AI agent built with Sui's latest random modules, seamlessly integrated with Walrus for static content storage.", 
        b"https://github.com/xiaodi007/AI-CardGame", 
        b"https://xq917z4n9e1acc9lljw6lhopnjigg0xdu971sb07w0pdrs8rs.walrus.site/", 
        b"DiGYqS9SVCvlyIVgP22LhxVBPcY5ECCtiNqCugYPjAc"
      ],
      vector[
        b"Sui-Gallery", 
        b"AI-decentralized art gallery where anyone can be an artist or a collector. How it works: Create your art with the help of AI and mint it as your own. Showcase your art on a stand-alone Walrus Site where interested buyers can bid a price for it.", 
        b"https://github.com/SuiGallery/sui_gallery", 
        b"https://6683buvw2z7jvkg37ufutxtei0beoo45uew8vmr7uxa2vnkhxg.walrus.site/", 
        b"JopvwwiMJPbXnuVesP8KF-Y4GVDVbIwpsCdLoArWgR8"
      ],
      vector[
        b"SuiSurvey", 
        b"On-chain survey/polling/voting. Ensured privacy, data safety, security and ease of reward distribution. ", 
        b"https://github.com/sui-survey/suisurvey", 
        b"https://sui-survey.walrus.site/", 
        b""
      ],
      vector[
        b"SuiPump:Token Market", 
        b"Token Market project was inspired by PumpFun. Since PumpFun is a token trading market on the Solana blockchain, we wanted to implement similar functionality on the Sui blockchain. We modeled the frontend layout after PumpFun and used React, Vue3, and Vite as our frontend technology stack, with Go as the backend API architecture. We built a system on the SuiPump website that enables token creation, trading, and other functionalities. Token trading is controlled by a bonding curve, where the token price increases as more people purchase it. The frontend is fully deployed on Walrus, with most functionalities implemented on the frontend, except for some information retrieved via API requests.\n\nThe reason for using the API is that when a user creates a coin, we generate a new address for that coin to facilitate trading. To complete functions like address creation, contract deployment, and information entry, we deal with dynamic data that is difficult to associate through Walrus alone, so we also store this information in a MySQL database to prevent data loss during testing. While the main page and the display of user-created coins are handled by reading backend information, all other coin information displays are achieved by executing queries and commands directly on the frontend.\n\nDue to limitations in team size and technical expertise, I encountered many issues, particularly with communication between the frontend and my own server. Since this was my first time working on such a large project, and I was learning as I went along, there are still some unresolved stability issues. On the Walrus site, sometimes the entire process works smoothly, while at other times, bugs occur. However, overall, the project successfully implements trading functionalities and visualizes trading information. \n\nThis has been a journey of learning and implementing Sui Move from 0 to 1, and I hope to continue improving in the future. I sincerely welcome your feedback and suggestions! Thank you!", 
        b"https://github.com/Ocrand/SuiPump-Token-Market", 
        b"https://suipump.walrus.site/", 
        b"bBAbolNOw2thYlJLAoucyoP0l9Brgtcl4p6-BMy7BG4"
      ],
      vector[
        b"SecretLink", 
        b"Walrus Protocol-based encrypted storage facilities allow us to manage users' encrypted data in a faster and more manageable manner\n\nFeature:\n1. End-to-End Encryption\nYour data is encrypted before it leaves your device.\n\n2. Immutable Records\nSui Blockchain And Walrus Protocol ensures your shared content remains tamper-proof and verifiable.\n\n3. Decentralized Security\nNo single point of failure. Your data is distributed across the network.\n\n\nHow SecretLink Works\n\n1. Upload Content\nUpload your file or enter text to be encrypted.\n\n2. Generate Encryption Key\nA unique encryption key is generated in your browser.\n\n3. Encrypt Data\nYour content is encrypted using AES encryption.\n\n4. Store Encrypted Data\nEncrypted data is stored in SUI Walrus distributed storage.\n\n5. Generate Shareable Link\nA unique link is created for accessing the encrypted content.", 
        b"https://github.com/Euraxluo/secretlink", 
        b"https://secretlink.walrus.site/", 
        b"bausJtj8WRn-LaRyZzK1Z-TWAxvtIj99nQDrrVz1WJk"
      ],
      vector[
        b"MvnToWalrus", 
        b"Mvn to walrus is a mvn plugin to upload file to walrus in mvn lifecycle.", 
        b"https://github.com/willser/mvnTowalrus", 
        b"https://maven.walrus.site/", 
        b"ALOQpoCBeDVrT7XureqUw9KIrlu6bLIGiz0vtkvx69Q"
      ],
      vector[
        b"Suiftly.io", 
        b"CDN optimizations for Sui Walrus. Load most blobs under 100 milliseconds. \n\nMany ways to integrate, including a NPM package for automatic CDN to Walrus failover and blob authentication.\n\nDemo: https://suiftly.walrus.site\n\nVideo: https://cdn.suiftly.io/blob/a4D3emjgYleUSuCuaIu51b6PAEBiC_ddd9dzspovhiU\n\nMore info: https://suiftly.io", 
        b"https://github.com/chainmovers/suiftly", 
        b"https://suiftly.walrus.site", 
        b"a4D3emjgYleUSuCuaIu51b6PAEBiC_ddd9dzspovhiU"
      ],
      vector[
        b"Walrus game", 
        b"A little game about walruses, penguins, and fish. Each walrus minted comes with its own site tied to the NFT. Use the walrus to catch fish, the fire to cook the fish, and then buy penguins with cooked fish who will then catch more fish for you. The walrus with the most penguins and fish wins.", 
        b"https://github.com/builders-of-stuff/walrus-game", 
        b"https://27cq3tlycwm5nihei6oxv6pbo2c1z5dpv6y67e7ux6swvwgra8.walrus.site/", 
        b"13syIo0JUrTtS1tgXulsR-JlcTlbwrdmC-6Q7_H-hPg"
      ],
      vector[
        b"DriftBottle", 
        b"Drift bottle on chain：\n- Is there something you've always wanted to say but never found the courage? What are you afraid of? What’s holding you back? Send a drift bottle and release the words that have been weighing on your heart.\n- Is there someone you can't stop thinking about, someone you long to speak to but don’t dare? Write your feelings in a drift bottle, and maybe it will find its way to them.\n- Has anyone ever told you, \"I love you more than anything\"?\n- Feeling overwhelmed? Need a place to let it all out? Write down the burdens on your heart and send them drifting away.\n- Did you know? That year, I waited for you… until the very end. ", 
        b"https://github.com/orgs/DriftBottleOnSui/repositories", 
        b"https://drift-bottle.walrus.site/", 
        b"9sINIHO2nHR0usD8ZBlX1FdqEsmbefwhU1Wc0XhQsmg"
      ],
      vector[
        b"Diffend - Divergence Terminator", 
        b"Diffend is a decentralized disagreement finisher used to resolve previous disagreements between people and record them permanently on the blockchain. Users add bets, and the winner wins the bet. Those who participate in the voting also receive a 10% reward.", 
        b"https://github.com/Wujerry/diffend-walrus-sites", 
        b"https://diffend.walrus.site/", 
        b"8OtVO0d5cavTrMxAjZP-VKsjaSu3OUpI6r0HeyKxuP8"
      ],
      vector[
        b"sui-ai-agents", 
        b"Sui-AI-Agents introduces a cutting-edge decentralized AI agent network that merges AI with web3, aiming to create a permissionless network for AI agents. Utilizing web3, it pioneers an Artificial Intelligence finance system (AiFi), enhancing transparency, security, and efficiency in deploying, operating, and transacting AI services via blockchain. Sui-AI-Agents envisions a future of decentralized intelligent services and financial ecosystems, offering an accessible, reliable platform for developers, businesses, and users to exchange and manage AI services.\n\nThis platform streamlines the operational framework for AI agents, simplifying the process of managing APIs and subscriptions by utilizing Agent services. These services enable agents to autonomously make decisions and take actions without manual API integrations, facilitated by the integration of cryptocurrency transactions within a decentralized AI financial system.\n\nSui-AI-Agents use Walrus to store call agent results, so everything is fully decentralized", 
        b"https://github.com/fantasyni/sui-ai-agents", 
        b"https://2yjupvm8x2yun1ooob9yu7ixkp4a1irk10xnn5sd94ra3dbhva.walrus.site/#/", 
        b"3yEQlCV_2fQ4ZETNNUnLdmv2BPQFi5EpZAVtN-izRTo"
      ],
      vector[
        b"WoodenFish", 
        b"Knocking on the cyber woodchuck, accumulating cyber merit.", 
        b"https://github.com/greycodee/merit", 
        b"https://4amcibwhmk4xc89vj79ezkjqzg6kpri088sqm8yrw8mhgehe5r.walrus.site", 
        b"3rzu4_nnyX6MkCt6n0uvCXpNwHj44iAjmTw_AJFr01A"
      ],
      vector[
        b"Vanishr", 
        b"Vanishr aims to provide a secure and private file sharing platform. By leveraging web3 technology and the Walrus storage system, it achieves encrypted file storage and self-destructing functionality.", 
        b"https://github.com/alva-lin/vanishr", 
        b"https://vanishr.walrus.site", 
        b"2bQNFFuHvMu6-wQnPZxFfNBzhUEl64S9FuxOiL-1v8A"
      ],
      vector[
        b"Tuskscipt", 
        b"TuskScript is a TypeScript-based npm package designed to simplify development on the Walrus network. By providing an intuitive API for seamless data storage and retrieval, TuskScript enables developers to easily integrate decentralized storage solutions into both Web2 and Web3 applications. With built-in support for TypeScript types and flexible data handling, TuskScript bridges the gap between traditional and decentralized data availability, making it easier than ever to build innovative blockchain applications with minimal effort.\n\nIn addition to TuskScript, this project includes a starter kit called create-tusk-app, which helps developers integrate Sui and Walrus into their React applications. What makes this template unique is its ability to convert a React app into a Walrus dApp that can be deployed directly on the Walrus network. For more details, check out the README.md at https://github.com/Sorbin/tusk-dapp?tab=readme-ov-file#deploying-to-walrus  and the live tusk-dapp on Walrus at https://4b90hd5a1rmgzt5bkgq0bcsi2x9rq3u6gmi8ek6vm240spjogd.walrus.site/.\n\nStart integrating Walrus into your dApp with npm i tuskscript, or create a new unique idea on Sui and Walrus with npx create-tusk-app.\n\n- Demo Video BlobID (download as .mp4): X3Uqsqz52OaaNzqjY3_mlQjfHK2yNiIIooRrBvf3I\n- tuskscript NPM: https://www.npmjs.com/package/tuskscript\n- tuskscript Source: https://github.com/Sorbin/tuskscript\n- create-tusk-app NPM: https://www.npmjs.com/package/create-tusk-app\n- create-tusk-app on Walrus: https://4b90hd5a1rmgzt5bkgq0bcsi2x9rq3u6gmi8ek6vm240spjogd.walrus.site/\n\n- create-tusk-app Source: https://github.com/Sorbin/create-tusk-app", 
        b"https://github.com/SovaSniper/tuskscript", 
        b"https://4b90hd5a1rmgzt5bkgq0bcsi2x9rq3u6gmi8ek6vm240spjogd.walrus.site", 
        b"2-X3Uqsqz52OaaNzqjY3_mlQjfHK2yNiIIooRrBvf3I"
      ],
      vector[
        b"Time Capsule", 
        b"It is a decentralized platform that allows users to store their future words and wishes on the blockchain. Users can record their thoughts and set unlock dates to motivate future self reflection, growth, and change.", 
        b"https://github.com/houddup/time_capsule_ui", 
        b"https://42eh3u0w42kfgdidgtdtn0mojjkv3bbskng6jnalmj40wk93mn.walrus.site/", 
        b""
      ],
      vector[
        b"Promise", 
        b"Promise is a quiz platform leveraging zero-knowledge proofs to create an engaging experience which combats ad fatigue through meaningful ad engagement.", 
        b"https://github.com/arty-arty/promise-zk", 
        b"https://promise.walrus.site/", 
        b"00jPbQPmgNiSUOxsSvULn9p6q8GRmQtCp8niQF_KD6s"
      ],
      vector[
        b"Random Direction Shoot Game", 
        b"GAME RULES\n\nnormal mode:\n\nW/A/S/D or Arrow keys to move.\n\nFire bullets randomly.\n\nPoints are scored based on the initial radius of enemies destroyed.\n\nAfter 100 bullets, the score will be settled.\n\nIf your score can be on the list (top ten), you can choose to pay a certain amount to update the list and get a unique NFT collection at the same time.\n\nrainbow mode:\n\nYour bullets will be of random colors, and bullets of different colors have different effects.\n\nWhen you give a fatal blow, your score may increase significantly.\n\nIt is worth noting that you need to pay a certain amount in advance to enable rainbow mode.", 
        b"https://github.com/zcy1024/WalrusDevnetHackathon", 
        b"https://zcy1024-walrusdevnethackathon.walrus.site/", 
        b"lzHY6gnFLr3ZhLraFELutYNEso6GczYPyGWzdJTUQ3w"
      ],
      vector[
        b"Suitizen", 
        b"Suitizen is an on-chain identity initiative. Our mission is to create an identity card fully compatible with the SUI network, empowering citizens with the rights to participate in various on-chain community activities.\n\nUsers can purchase the SUI Name Service and then apply for an identity card on the Suitizen website. During the application process, we scan your facial features and, incorporating some randomness, generate an avatar that represents you in the SUI world. This avatar is immutable, reflecting the idea that one cannot change their appearance in the real world. Your facial features, along with the generated avatar, are encrypted and recorded on Walrus.\n\nWe are also building an on-chain community that includes activities like \"Discussion\" and \"Voting\". In the future, we plan to expand the community with more activities.\n\nNow, Let's become a Suitizen!", 
        b"https://github.com/CJMario89/suitizen", 
        b"https://suitizen.walrus.site/", 
        b"-BM_1f-EF2QzxCfSQeQuWxjgs8aNLRa2WTZd-tzDvZw"
      ],
    ];

    let mut project_list = vector[];

    let mut index = 0;

    while (index < projects.length()) {
      project_list.push_back(Project {
        id: index, 
        votes: 0, 
        name: projects[index][0].to_string(), 
        description: projects[index][1].to_string(), 
        github_url: url::new_unsafe(projects[index][2].to_ascii_string()), 
        walrus_site_url: url::new_unsafe(projects[index][3].to_ascii_string()), 
        video_blob_id: projects[index][4].to_string()
      });

      index = index + 1;
    };

    let votes = Votes {
      id: object::new(ctx),
      total_votes: 0, 
      project_list,
      votes: table::new(ctx),
      voting_active: false
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
    let mut curr_index = 0;
    while (curr_index < project_ids.length()) {
      let project = &mut votes.project_list[project_ids[curr_index]];
      project.votes = project.votes + 1;

      // Increment total votes
      votes.total_votes = votes.total_votes + 1;

      curr_index = curr_index + 1;
    };

    // Record user's vote
    table::add(
      &mut votes.votes, 
      voter, 
      project_ids
    );
  }

  public entry fun toggle_voting(_: &AdminCap, can_vote: bool, votes: &mut Votes) {
    votes.voting_active = can_vote;
  }

  fun assert_user_has_not_voted(user: address, votes: &Votes) {
    assert!(
      table::contains(
        &votes.votes, 
        user
      ) == false, 
      EUserAlreadyVoted
    );
  }

  fun assert_valid_project_ids(project_ids: vector<u64>, votes: &Votes) {
    // assert!(
    //   project_ids.length() <= 3, 
    //   ETooManyVotes
    // );
    
    let mut curr_index = 0;
    let mut ids = vec_map::empty();
    while (curr_index < project_ids.length()) {
      assert!(
        project_ids[curr_index] < votes.project_list.length(),
        EInvalidProjectId
      );
      vec_map::insert(&mut ids, project_ids[curr_index], 0); // this will abort if there is a dup
      curr_index = curr_index + 1;
    };
  }

  fun assert_voting_is_active(votes: &Votes) {
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
}
