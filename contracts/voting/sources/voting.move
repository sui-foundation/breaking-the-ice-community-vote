
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
    let votes = Votes {
      id: object::new(ctx),
      total_votes: 0, 
      project_list: vector[
        Project {
          id: 0, 
          name: b"Sui Jump".to_string(),
          description: b"A game relying on walrus decentralized storage.".to_string(),
          video_blob_id: b"U5CjLKjN_jSmpzBpQiqi7-DwLRhTDXfng5FsM_LMky4".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://1vhr1c50tul218ayp0b1dif7e1lrcx1tmu58o97lp8u04m034z.walrus.site"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/djytwy/Sui_jump"),
          votes: 0,
        },
        Project {
          id: 1, 
          name: b"Walrus Pass".to_string(),
          description: b"Walrus Pass is an innovative solution designed to securely manage and verify digital assets such as subscription models, proof of purchase, concert tickets, licenses, and more. Leveraging the security and transparency of blockchain technology, Walrus Pass enables users to effectively prove their rights to various assets.".to_string(),
          video_blob_id: b"tafMqHCbsQZ99sofKgsOI1dHxepBvOlq1PmR-Oy9hrA".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://docs.zktx.io/walrus/walrus-pass.html"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/zktx-io/walrus-pass-monorepo"),
          votes: 0,
        },
        Project {
          id: 2, 
          name: b"Simple PKI prototype with Walrus".to_string(),
          description: b"Actual PKI or CA is mostly used for communications between users and companies. It involves with HTTPS, DNSSEC, and secure software installation. While users and users can still communicate by using certificates created from custom PKI/CA, it will be overkill, complicated and high costs if the communications were changed from users and companies into users and users. This prototype will be creating a simple CA that can be used specifically for small scale user to user communication. ".to_string(),
          video_blob_id: b"OqZ2CJnV1RmZ_9kQv2I7GK5AL_dlZfs1fgyupcahtpc".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://dspkiproto.walrus.site/"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/Chewhern/Walrus_HApp"),
          votes: 0,
        },
        Project {
          id: 3, 
          name: b"WalrusFS".to_string(),
          description: b"Imagine a decentralized file system, like a windows operating system. When I upload a file to walrus, the system can display a file and point to a blob_id. I can easily download the file stored in walrus by clicking on the file, and then do more".to_string(),
          video_blob_id: b"nHvgjOoxsd7jGQOQCKqZb48L4dYNrXh6jZuh3dAe5h0".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://walrusfs.walrus.site"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/applesline/WalrusFS.git"),
          votes: 0,
        },
        Project {
          id: 4, 
          name: b"JarJar FileStorage".to_string(),
          description: b"Fully decentralized user friendly file storage solution that can store on Walrus or directly on SUI blockchain\n\nX: @JARJARxyz".to_string(),
          video_blob_id: b"muE11mnnLvstleoL4az8h0Y_psuY88CaENoNi0W1N8o".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://19mxww1lum74y3yg9o26rxtu2i5pvxq6ff66cz88v4nqi3kw3p.walrus.site/"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/orgs/jarjar-xyz/repositories"),
          votes: 0,
        },
        Project {
          id: 5, 
          name: b"MvnToWalrus".to_string(),
          description: b"Mvn to walrus is a mvn plugin to upload file to walrus in mvn lifecycle.".to_string(),
          video_blob_id: b"LOQJ4xS43eoBmOqp0ciA5XAP3zSH_Gfbo9_1KrMR-k8".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://maven.walrus.site/"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/willser/mvnTowalrus"),
          votes: 0,
        },
        Project {
          id: 6, 
          name: b"Walrus Sites GA".to_string(),
          description: b"Using GitHub Actions to deploy a Walrus website provides an automated workflow that allows automatic deployment with each code change, eliminating the need to worry about Walrus CLI configurations. In addition, GitHub simplifies version control and history tracking, providing clear proof of origin for each deployment, increasing reliability and transparency.".to_string(),
          video_blob_id: b"JSQ-xt7E7KNSKgiAL3IBT5B5_3Hk_ZMiMZFHGqynkYU".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://github.com/marketplace/actions/walrus-sites-ga"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/zktx-io/walrus-sites-ga"),
          votes: 0,
        },
        Project {
          id: 7, 
          name: b"Doomsday Protocol: Rebirth in Another World".to_string(),
          description: b"A strategic card battle game featuring an AI agent built with Sui's latest random modules, seamlessly integrated with Walrus for static content storage.".to_string(),
          video_blob_id: b"DiGYqS9SVCvlyIVgP22LhxVBPcY5ECCtiNqCugYPjAc".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://xq917z4n9e1acc9lljw6lhopnjigg0xdu971sb07w0pdrs8rs.walrus.site/"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/xiaodi007/AI-CardGame"),
          votes: 0,
        },
        Project {
          id: 8, 
          name: b"Sui-Gallery".to_string(),
          description: b"AI-decentralized art gallery where anyone can be an artist or a collector. How it works: Create your art with the help of AI and mint it as your own. Showcase your art on a stand-alone Walrus Site where interested buyers can bid a price for it.".to_string(),
          video_blob_id: b"JopvwwiMJPbXnuVesP8KF-Y4GVDVbIwpsCdLoArWgR8".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://6683buvw2z7jvkg37ufutxtei0beoo45uew8vmr7uxa2vnkhxg.walrus.site/"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/SuiGallery/sui_gallery"),
          votes: 0,
        },
        Project {
          id: 9, 
          name: b"SuiSurvey".to_string(),
          description: b"On-chain survey/polling/voting. Ensured privacy, data safety, security and ease of reward distribution. ".to_string(),
          video_blob_id: b"".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://sui-survey.walrus.site/"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/sui-survey/suisurvey"),
          votes: 0,
        },
        Project {
          id: 10, 
          name: b"Suiftly.io".to_string(),
          description: b"CDN optimizations for Sui Walrus. Load most blobs under 100 milliseconds. \n\nMany ways to integrate, including a NPM package for automatic CDN to Walrus failover and blob authentication.\n\nDemo: https://suiftly.walrus.site\n\nVideo: https://cdn.suiftly.io/blob/a4D3emjgYleUSuCuaIu51b6PAEBiC_ddd9dzspovhiU\n\nMore info: https://suiftly.io".to_string(),
          video_blob_id: b"a4D3emjgYleUSuCuaIu51b6PAEBiC_ddd9dzspovhiU".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://suiftly.walrus.site"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/chainmovers/suiftly"),
          votes: 0,
        },
        Project {
          id: 11, 
          name: b"Diffend - Divergence Terminator".to_string(),
          description: b"Diffend is a decentralized disagreement finisher used to resolve previous disagreements between people and record them permanently on the blockchain. Users add bets, and the winner wins the bet. Those who participate in the voting also receive a 10% reward.".to_string(),
          video_blob_id: b"8OtVO0d5cavTrMxAjZP-VKsjaSu3OUpI6r0HeyKxuP8".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://diffend.walrus.site/"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/Wujerry/diffend-walrus-sites"),
          votes: 0,
        },
        Project {
          id: 12, 
          name: b"sui-ai-agents".to_string(),
          description: b"Sui-AI-Agents introduces a cutting-edge decentralized AI agent network that merges AI with web3, aiming to create a permissionless network for AI agents. Utilizing web3, it pioneers an Artificial Intelligence finance system (AiFi), enhancing transparency, security, and efficiency in deploying, operating, and transacting AI services via blockchain. Sui-AI-Agents envisions a future of decentralized intelligent services and financial ecosystems, offering an accessible, reliable platform for developers, businesses, and users to exchange and manage AI services.\n\nThis platform streamlines the operational framework for AI agents, simplifying the process of managing APIs and subscriptions by utilizing Agent services. These services enable agents to autonomously make decisions and take actions without manual API integrations, facilitated by the integration of cryptocurrency transactions within a decentralized AI financial system.\n\nSui-AI-Agents use Walrus to store call agent results, so everything is fully decentralized".to_string(),
          video_blob_id: b"3yEQlCV_2fQ4ZETNNUnLdmv2BPQFi5EpZAVtN-izRTo".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://2yjupvm8x2yun1ooob9yu7ixkp4a1irk10xnn5sd94ra3dbhva.walrus.site/#/"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/fantasyni/sui-ai-agents"),
          votes: 0,
        },
        Project {
          id: 13, 
          name: b"Tuskscipt".to_string(),
          description: b"TuskScript is a TypeScript-based npm package designed to simplify development on the Walrus network. By providing an intuitive API for seamless data storage and retrieval, TuskScript enables developers to easily integrate decentralized storage solutions into both Web2 and Web3 applications. With built-in support for TypeScript types and flexible data handling, TuskScript bridges the gap between traditional and decentralized data availability, making it easier than ever to build innovative blockchain applications with minimal effort.\n\nIn addition to TuskScript, this project includes a starter kit called create-tusk-app, which helps developers integrate Sui and Walrus into their React applications. What makes this template unique is its ability to convert a React app into a Walrus dApp that can be deployed directly on the Walrus network. For more details, check out the README.md at https://github.com/Sorbin/tusk-dapp?tab=readme-ov-file#deploying-to-walrus  and the live tusk-dapp on Walrus at https://4b90hd5a1rmgzt5bkgq0bcsi2x9rq3u6gmi8ek6vm240spjogd.walrus.site/.\n\nStart integrating Walrus into your dApp with npm i tuskscript, or create a new unique idea on Sui and Walrus with npx create-tusk-app.\n\n- Demo Video BlobID (download as .mp4): X3Uqsqz52OaaNzqjY3_mlQjfHK2yNiIIooRrBvf3I\n- tuskscript NPM: https://www.npmjs.com/package/tuskscript\n- tuskscript Source: https://github.com/Sorbin/tuskscript\n- create-tusk-app NPM: https://www.npmjs.com/package/create-tusk-app\n- create-tusk-app on Walrus: https://4b90hd5a1rmgzt5bkgq0bcsi2x9rq3u6gmi8ek6vm240spjogd.walrus.site/\n\n- create-tusk-app Source: https://github.com/Sorbin/create-tusk-app".to_string(),
          video_blob_id: b"2-X3Uqsqz52OaaNzqjY3_mlQjfHK2yNiIIooRrBvf3I".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://4b90hd5a1rmgzt5bkgq0bcsi2x9rq3u6gmi8ek6vm240spjogd.walrus.site"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/SovaSniper/tuskscript"),
          votes: 0,
        },
        Project {
          id: 14, 
          name: b"Random Direction Shoot Game".to_string(),
          description: b"GAME RULES\n\nnormal mode:\n\nW/A/S/D or Arrow keys to move.\n\nFire bullets randomly.\n\nPoints are scored based on the initial radius of enemies destroyed.\n\nAfter 100 bullets, the score will be settled.\n\nIf your score can be on the list (top ten), you can choose to pay a certain amount to update the list and get a unique NFT collection at the same time.\n\nrainbow mode:\n\nYour bullets will be of random colors, and bullets of different colors have different effects.\n\nWhen you give a fatal blow, your score may increase significantly.\n\nIt is worth noting that you need to pay a certain amount in advance to enable rainbow mode.".to_string(),
          video_blob_id: b"lzHY6gnFLr3ZhLraFELutYNEso6GczYPyGWzdJTUQ3w".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://zcy1024-walrusdevnethackathon.walrus.site/"),
          github_url: url::new_unsafe_from_bytes(b"https://github.com/zcy1024/WalrusDevnetHackathon"),
          votes: 0,
        },
      ],
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
