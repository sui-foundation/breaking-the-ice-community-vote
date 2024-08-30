
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
          name: b"suiS3".to_string(),
          description: b"S3 Simple Storage Service Protocol Written In Walrus".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 1, 
          name: b"SuiIP".to_string(),
          description: b"SuiIP is the IP protection built for artist, content creators & NFT holders to list their IPs and earn royalties when IP is used by anyone on Sui ecosystem. This could be used by on-chain games to import digital assets like game characters directly into the game while protecting it's IP & earn royalties on top of this. ".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 2, 
          name: b"SuiChat".to_string(),
          description: b"Sui chat is the first p2p & group chatting protocol built on Sui & walrus. It leverages walrus to store media (like images & videos) & Sui network to send messages p2p. This platform is built to bring entire Sui community on-chain(from discord ofc!). A simple KYC process could be used to link twitter accounts with on-chain addresses & directly login using NFTs & SuiNS. Different Dapps can have their on group chats with gated access.".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 3, 
          name: b"tuskscipt".to_string(),
          description: b"".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 4, 
          name: b"de-docker-hub".to_string(),
          description: b"Decentralized Docker Hub, store the Docker image in walrus".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 5, 
          name: b"Arrow".to_string(),
          description: b"A secure way for sharing files.".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 6, 
          name: b"Nemo Protocol".to_string(),
          description: b"The yield trading app on Sui. Fixed return & Leveraged yield. ".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 7, 
          name: b"Walrus Guard".to_string(),
          description: b"SaaS for Enterprise Disaster Recovery starting with a fremium model, key features to include -\n1. Scheduling of automated backups\n2. Secure and gated access control via multisig\n3. Quick recovery and redeploy\n4. Compliance Management etc".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 8, 
          name: b"Suiftly.io".to_string(),
          description: b"CDN optimizations for Sui Walrus. Load most blob under 100 milliseconds. \n\nMany ways to integrate, including a NPM package for automatic CDN to Walrus failover and CDN delivered blob validation.\n\nSee https://suiftly.io".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 9, 
          name: b"Mojo".to_string(),
          description: b"I want to integrate music and crypto where artists will be paid thru sui rather than other forms of payments.".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 10, 
          name: b"JarJar protocol".to_string(),
          description: b"Ai gen protocol on SUI blockchain".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 11, 
          name: b"LaplacePad".to_string(),
          description: b"A token distribution project based on a lottery system.".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 12, 
          name: b"walrus-ga".to_string(),
          description: b"Using GitHub Actions to deploy a Walrus website provides an automated workflow that allows automatic deployment with each code change, eliminating the need to worry about Walrus CLI configurations. In addition, GitHub simplifies version control and history tracking, providing clear proof of origin for each deployment, increasing reliability and transparency.".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 13, 
          name: b"NetSepio".to_string(),
          description: b"NetSepio is revolutionizing internet access through the power of DePIN, empowering anyone to set up a VPN node and share their internet bandwidth, thus fostering a network that is both secure and universally accessible. By combining decentralized VPN (dVPN) and decentralized WiFi (dWiFi) technologies, our mission is to make the internet safer, more private, and available to everyone. We achieve this using cutting-edge technologies like zero-knowledge proofs to secure your data, AI-driven tools to detect and respond to threats proactively, and blockchain to ensure transparency and decentralization. Whether you're a business looking to protect your employees and subsidize internet costs for your users or an individual seeking private, high-speed internet, Erebrus offers a versatile and secure solution, transforming the way we experience the digital world.".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 14, 
          name: b"walrus-press".to_string(),
          description: b"WalrusPress is a markdown-centered static site generator. You can write your content (documentations, blogs, etc.) in Markdown, then WalrusPress will help you to generate a static site to host them.".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 15, 
          name: b"Galliun".to_string(),
          description: b"Galliun is developing  Water Cooler Protocol a minting and distribution protocol for NFT collection launches on Sui along with Flow a Command Line Tool for interfacing with the Water Cooler Protocol.".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 16, 
          name: b"Online Selling Platforms".to_string(),
          description: b"This website is created to create an e-commerce selling website.".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 17, 
          name: b"Xbuild".to_string(),
          description: b"storage platform ".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 18, 
          name: b"Adgraph".to_string(),
          description: b"AdGraph is an open, decentralized on-chain graph of user preferences.".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 19, 
          name: b"PackMyEvent".to_string(),
          description: b"PackMyEvent leverages the unique features of the Sui blockchain, such as its innovative data model that treats each digital asset as a truly unique and indivisible entity. This approach ensures that event tickets are secured as non-fungible tokens (NFTs), granting unprecedented ownership and control to users.".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 20, 
          name: b"Suitizen".to_string(),
          description: b"Suitizen is an on-chain identity project. Our vision is to create an identity card that is fully supported across the SUI network, granting citizens the rights they should have, such as participating in various on-chain activities like voting.\n\nUsers can purchase the SUI Name Service and then apply for an identity card on the Suitizen website. During the application process, we will scan your facial features and, with some randomness, generate an avatar representing you in the SUI world. This avatar is immutable, just like how you can't change your appearance in the real world. Your facial features, along with the generated avatar, will be encrypted and recorded on Walrus.\n\nTo prevent the abuse of identity issuance, obtaining a Suitizen identity card requires prior purchase of the SUI Name Service and is tied to your facial features.\n\nBecome a Suitizen now!".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 21, 
          name: b"keybase".to_string(),
          description: b"KV store on Walrus".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 22, 
          name: b"Essential DAO ".to_string(),
          description: b"Providing DAO solutions in the sui ecosystem ".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
          votes: 0,
        },
        Project {
          id: 23, 
          name: b"Split Conferencing ".to_string(),
          description: b"Say a team got a page that there application is down and there need to be a medium where everyone can join into one call and split into rooms and seamlessly switch between the rooms.\n\nRooms in the above scenario can be like front end room, backend room, network room and DB room etc\n\nSo everyone can do their own RCA".to_string(),
          video_blob_id: b"rvtweti0wlA0OeIO_Vi2sdvqV29zLDfO63Lo-sFevVM".to_string(),
          walrus_site_url: url::new_unsafe_from_bytes(b"https://breakingtheice.walrus.site"),
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

    // assert_user_has_not_voted(voter, votes);
    assert_sender_zklogin(address_seed, ctx);
    assert_valid_project_ids(project_ids, votes);
    // assert_voting_is_active(votes);

    // Update project's vote
    let mut curr_index = 0;
    while (curr_index < project_ids.length()) {
      let project = &mut votes.project_list[project_ids[curr_index]];
      project.votes = project.votes + 1;

      // Increment total votes
      votes.total_votes = votes.total_votes + 1;

      curr_index = curr_index + 1;
    };

    // // Record user's vote
    // table::add(
    //   &mut votes.votes, 
    //   voter, 
    //   project_ids
    // );
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
