module voting::approval;

use voting::voting::{Votes, Project, AdminCap, new_votes, vote_internal,
assert_token_in_whitelist, assert_valid_project_ids, assert_voting_is_active};
use sui::random::{Random};
use sui::table;
use std::debug;

public struct ProjectWithAddress has drop {
  project: Project,
  address: address,
}

public struct TeamOrca has key { id: UID }
public struct TeamPolarBear has key { id: UID }

const ENotSameLength: u64 = 1;

fun init(_: &mut TxContext) {}

// AdminCap is required to create a shortlist
entry fun create_shortlist(_: &AdminCap, votes: &Votes, project_ids: vector<u64>, addresses: vector<address>, r: &Random, ctx: &mut TxContext) {
  assert!(project_ids.length() == addresses.length(), ENotSameLength);
  let mut projects = project_ids.zip_map!(addresses, |i, a| {
    let p = votes.project_list(i);
    ProjectWithAddress {
      project: p,
      address: a,
    }
  });

  // Split shortlist into 2 teams
  let mut rng = r.new_generator(ctx);
  rng.shuffle(&mut projects);

  let mut team_orca = new_votes<TeamOrca>(
    0,
    table::new(ctx),
    table::new(ctx),
    false,
    ctx
  );
  let mut team_polar_bear = new_votes<TeamPolarBear>(
    0,
    table::new(ctx),
    table::new(ctx),
    false,
    ctx
  );

  // divide the projects into 2 teams
  // if the number of projects is odd, the first team will have 1 more project
  let n = projects.length();
  debug::print(&b"project length".to_string());
  debug::print(&n);
  let n1 = n / 2;

  vector::tabulate!(n, |i| {
    let p = projects.pop_back();
    if (i <= n1) {
      team_orca.append_project_list(p.project);
      transfer::transfer(TeamPolarBear{id: object::new(ctx)}, p.address);
      debug::print(&b"TeamPolarBear".to_string());
      debug::print(&p.address);
    } else {
      team_polar_bear.append_project_list(p.project);
      transfer::transfer(TeamOrca{id: object::new(ctx)}, p.address);
      debug::print(&b"TeamOrca".to_string());
      debug::print(&p.address);
    };
    true
  });

  team_orca.share_votes();
  team_polar_bear.share_votes();
  projects.destroy_empty();
}

public fun approve<T>(nft: &T, ballot: vector<u64>, v: &mut Votes, ctx: &TxContext) {
  assert_voting_is_active(v);
  assert_token_in_whitelist(nft, v);
  assert_valid_project_ids(ballot, v);
  
  vote_internal(v, ballot, ctx);
}
