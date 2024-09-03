#[test_only]
module voting::voting_tests;
// uncomment this line to import the module
use voting::voting::{Self, AdminCap, Votes, toggle_voting, ENotInWhitelist, EInvalidProjectId, EVotingInactive};
use voting::approval::{create_shortlist, TeamOrca, approve};
use sui::test_scenario::{Self as ts, Scenario};
use sui::random::{Self,Random};
use std::debug;

const ORGANIZER: address = @0xAAA;
const Voter1: address = @0x111;
const Voter2: address = @0x222;
const Voter3: address = @0x333;
const Voter4: address = @0x444;
const Voter5: address = @0x555;

#[test]
fun initialize(): Scenario {
    let mut scenario = ts::begin(ORGANIZER);
    voting::init_for_test(scenario.ctx());

    ts::next_tx(&mut scenario, @0x0);
    {
        random::create_for_testing(scenario.ctx());
    };

    ts::next_tx(&mut scenario, @0x0);
    let mut random_state: Random = scenario.take_shared();
    {
        random_state.update_randomness_state_for_testing(
            0,
            x"1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1F1FFF",
            scenario.ctx(),
        );
        ts::return_shared(random_state);
    };
    ts::next_tx(&mut scenario, ORGANIZER);
    {
        let random_state: Random = scenario.take_shared<Random>();
        let cap = scenario.take_from_sender<AdminCap>();
        let og_votes = scenario.take_shared<Votes>();
        let shortlisted_projects = vector[1, 2, 3, 4, 5];
        let whitelist_addresses = vector[Voter1, Voter2, Voter3, Voter4, Voter5];
        // Guaranteed to split the team the same way due to hardcoded randomness
        // TeamPolarBear: @0x222, @0x555, @0x444
        // TeamOrca: @0x111, @0x333
        create_shortlist(&cap, &og_votes, shortlisted_projects, whitelist_addresses, &random_state, scenario.ctx());
        ts::return_shared(og_votes);
        ts::return_shared(random_state);
        ts::return_to_sender(&scenario, cap);
    };
    scenario
}

#[test]
fun happy_path(): Scenario {
    let mut scenario = initialize();

    let effects = ts::next_tx(&mut scenario, ORGANIZER);
    let approval_votes = ts::shared(&effects);
    {
        let mut team_polar_bear_projects = scenario.take_shared_by_id<Votes>(approval_votes[0]);
        let mut team_orca_projects = scenario.take_shared_by_id<Votes>(approval_votes[1]);
        let cap = scenario.take_from_sender<AdminCap>();
        toggle_voting(&cap, true, &mut team_polar_bear_projects);
        toggle_voting(&cap, true, &mut team_orca_projects);
        ts::return_shared(team_polar_bear_projects);
        ts::return_shared(team_orca_projects);
        ts::return_to_sender(&scenario, cap);
    };


    // Team Orca member votes for project 4 and 5
    ts::next_tx(&mut scenario, Voter1);
    {
        let mut votes = scenario.take_shared_by_id<Votes>(approval_votes[0]);
        let orca = scenario.take_from_sender<TeamOrca>();
        debug::print(&votes);

        approve<TeamOrca>(&orca, vector[4, 5], &mut votes, scenario.ctx());

        ts::return_shared(votes);
        ts::return_to_sender(&scenario, orca);
    };
    ts::next_tx(&mut scenario, Voter3);
    {
        let mut votes = scenario.take_shared_by_id<Votes>(approval_votes[0]);
        let orca = scenario.take_from_sender<TeamOrca>();
        debug::print(&votes);

        approve<TeamOrca>(&orca, vector[4], &mut votes, scenario.ctx());

        ts::return_shared(votes);
        ts::return_to_sender(&scenario, orca);
    };
    // Revote #1
    ts::next_tx(&mut scenario, Voter1);
    {
        let mut votes = scenario.take_shared_by_id<Votes>(approval_votes[0]);
        let orca = scenario.take_from_sender<TeamOrca>();
        debug::print(&votes);

        approve<TeamOrca>(&orca, vector[5, 4], &mut votes, scenario.ctx());

        ts::return_shared(votes);
        ts::return_to_sender(&scenario, orca);
    };

    // Assert first vote
    ts::next_tx(&mut scenario, Voter1);
    {
        let votes = scenario.take_shared_by_id<Votes>(approval_votes[0]);
        debug::print(&votes);
        assert!(votes.project_list(4).project_votes() == 2);
        assert!(votes.project_list(5).project_votes() == 1);
        assert!(votes.total_votes() == 3);
        assert!(votes.ballots(Voter1) == vector[5, 4]);
        assert!(votes.ballots(Voter3) == vector[4]);
        ts::return_shared(votes);
    };

    // Revote #2
    ts::next_tx(&mut scenario, Voter1);
    {
        let mut votes = scenario.take_shared_by_id<Votes>(approval_votes[0]);
        let orca = scenario.take_from_sender<TeamOrca>();
        debug::print(&votes);

        // Team Orca member votes for project 4 and 5
        approve<TeamOrca>(&orca, vector[2], &mut votes, scenario.ctx());

        ts::return_shared(votes);
        ts::return_to_sender(&scenario, orca);
    };
    // Assert revote
    ts::next_tx(&mut scenario, Voter1);
    {
        let votes = scenario.take_shared_by_id<Votes>(approval_votes[0]);
        debug::print(&votes);
        assert!(votes.project_list(2).project_votes() == 1);
        assert!(votes.project_list(4).project_votes() == 1);
        assert!(votes.project_list(5).project_votes() == 0);
        assert!(votes.total_votes() == 2);
        assert!(votes.ballots(Voter1) == vector[2]);
        assert!(votes.ballots(Voter3) == vector[4]);
        ts::return_shared(votes);
    };

    scenario
}

#[test]
#[expected_failure(abort_code = EVotingInactive)]
fun voting_not_active_error(): Scenario {
    let mut scenario = initialize();

    let effects = ts::next_tx(&mut scenario, ORGANIZER);
    let approval_votes = ts::shared(&effects);
    let team_polar_bear_id = approval_votes[0];

    // Team Orca member votes for project 4 and 5
    ts::next_tx(&mut scenario, Voter1);
    {
        let mut votes = scenario.take_shared_by_id<Votes>(team_polar_bear_id);
        let orca = scenario.take_from_sender<TeamOrca>();
        debug::print(&votes);

        approve<TeamOrca>(&orca, vector[4, 5], &mut votes, scenario.ctx());

        ts::return_shared(votes);
        ts::return_to_sender(&scenario, orca);
    };

    scenario
}

#[test]
#[expected_failure(abort_code = ENotInWhitelist)]
fun not_in_whitelist_error(): Scenario {
    let mut scenario = initialize();

    let effects = ts::next_tx(&mut scenario, ORGANIZER);
    let approval_votes = ts::shared(&effects);
    let team_polar_bear_id = approval_votes[0];
    let team_orca_id = approval_votes[1];
    {
        let mut team_polar_bear_projects = scenario.take_shared_by_id<Votes>(team_polar_bear_id);
        let mut team_orca_projects = scenario.take_shared_by_id<Votes>(team_orca_id);
        let cap = scenario.take_from_sender<AdminCap>();
        toggle_voting(&cap, true, &mut team_polar_bear_projects);
        toggle_voting(&cap, true, &mut team_orca_projects);
        ts::return_shared(team_polar_bear_projects);
        ts::return_shared(team_orca_projects);
        ts::return_to_sender(&scenario, cap);
    };

    // Team Orca member votes for Team Orca projects
    ts::next_tx(&mut scenario, Voter1);
    {
        let mut votes = scenario.take_shared_by_id<Votes>(team_orca_id);
        let orca = scenario.take_from_sender<TeamOrca>();
        debug::print(&votes);

        approve<TeamOrca>(&orca, vector[3], &mut votes, scenario.ctx());

        ts::return_shared(votes);
        ts::return_to_sender(&scenario, orca);
    };

    scenario
}

#[test]
#[expected_failure(abort_code = EInvalidProjectId)]
fun invalid_project_id_error(): Scenario {
    let mut scenario = initialize();

    let effects = ts::next_tx(&mut scenario, ORGANIZER);
    let approval_votes = ts::shared(&effects);
    let team_polar_bear_id = approval_votes[0];
    let team_orca_id = approval_votes[1];
    {
        let mut team_polar_bear_projects = scenario.take_shared_by_id<Votes>(team_polar_bear_id);
        let mut team_orca_projects = scenario.take_shared_by_id<Votes>(team_orca_id);
        let cap = scenario.take_from_sender<AdminCap>();
        toggle_voting(&cap, true, &mut team_polar_bear_projects);
        toggle_voting(&cap, true, &mut team_orca_projects);
        ts::return_shared(team_polar_bear_projects);
        ts::return_shared(team_orca_projects);
        ts::return_to_sender(&scenario, cap);
    };

    // Team Orca member tries to vote for project 1
    ts::next_tx(&mut scenario, Voter1);
    {
        let mut votes = scenario.take_shared_by_id<Votes>(team_polar_bear_id);
        let orca = scenario.take_from_sender<TeamOrca>();
        debug::print(&votes);

        approve<TeamOrca>(&orca, vector[1], &mut votes, scenario.ctx());

        ts::return_shared(votes);
        ts::return_to_sender(&scenario, orca);
    };

    scenario
}
