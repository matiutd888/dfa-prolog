%py expect_single_solution()
test_reverse_test_1_correct(S) :- pawel(reverse_test_1, A), correct(A, S).
test_reverse_test_2_correct(S) :- pawel(reverse_test_2, A), correct(A, S).
test_simple_path_1_correct(S) :- pawel(simple_path_1, A), correct(A, S).
test_single_node_correct(S) :- pawel(single_node, A), correct(A, S).
test_finite_compute_1_correct(S) :- pawel(finite_compute_1, A), correct(A, S).
test_finite_compute_2_correct(S) :- pawel(finite_compute_2, A), correct(A, S).
test_finite_compute_3_correct(S) :- pawel(finite_compute_3, A), correct(A, S).
test_state_before_start_1_correct(S) :- pawel(state_before_start_1, A), correct(A, S).
test_state_before_start_2_correct(S) :- pawel(state_before_start_2, A), correct(A, S).
test_state_before_start_3_correct(S) :- pawel(state_before_start_3, A), correct(A, S).
test_loop_in_another_branch_1a_correct(S) :- pawel(loop_in_another_branch_1a, A), correct(A, S).
test_loop_in_another_branch_1b_correct(S) :- pawel(loop_in_another_branch_1b, A), correct(A, S).
test_loop_in_another_branch_2a_correct(S) :- pawel(loop_in_another_branch_2a, A), correct(A, S).
test_loop_in_another_branch_2b_correct(S) :- pawel(loop_in_another_branch_2b, A), correct(A, S).

%py expect_success()
test_reverse_test_1_accept :- pawel(reverse_test_1, A), accept(A, [a, a, a, a, a]).
test_reverse_test_1_not_empty :- pawel(reverse_test_1, A), \+ empty(A).
test_reverse_test_2_accept :- pawel(reverse_test_2, A), accept(A, [a, a, a, a, a]).
test_reverse_test_2_not_empty :- pawel(reverse_test_2, A), \+ empty(A).
test_simple_path_1_accept :- pawel(simple_path_1, A), accept(A, [a]).
test_simple_path_1_accept2 :- pawel(simple_path_1, A), \+ accept(A, [a, a, a, a, a]).
test_simple_path_1_not_empty :- pawel(simple_path_1, A), \+ empty(A).
test_single_node_accept :- pawel(single_node, A), accept(A, [a, a, a, a, a]).
test_single_node_not_empty :- pawel(single_node, A), \+ empty(A).
test_empty_alphabet_incorrect :- pawel(empty_alphabet, A), \+ correct(A, _).
test_alphabet_compare_1_subsetEq :- pawel(alphabet_compare_1a, A), pawel(alphabet_compare_1b, B), \+ subsetEq(A, B), \+ subsetEq(B, A).
test_alphabet_compare_1_equal :- pawel(alphabet_compare_1a, A), pawel(alphabet_compare_1b, B), \+ equal(A, B), \+ equal(B, A).
test_simple_contain_1_subsetEqL :- pawel(simple_contain_1a, A), pawel(simple_contain_1b, B), subsetEq(A, B).
test_simple_contain_1_subsetEqR :- pawel(simple_contain_1a, A), pawel(simple_contain_1b, B), \+ subsetEq(B, A).
test_state_before_start_1 :- pawel(state_before_start_1, A), \+ empty(A).

test_finite_compute_1_accept(R) :- pawel(finite_compute_1, A), accept(A, R).
%py assert compare_word_sets(result, [['b']])
test_finite_compute_2_accept(R) :- pawel(finite_compute_2, A), accept(A, R).
%py assert compare_word_sets(result, [['b']])
test_finite_compute_3_accept(R) :- pawel(finite_compute_3, A), accept(A, R).
%py assert compare_word_sets(result, [['a']])

test_state_before_start_1_accept(R) :- pawel(state_before_start_1, A), accept(A, R).
%py assert compare_word_sets(result, [['a']])
test_state_before_start_2_accept(R) :- pawel(state_before_start_2, A), accept(A, R).
%py assert compare_word_sets(result, [['a']])
test_state_before_start_3_accept(R) :- pawel(state_before_start_3, A), accept(A, R).
%py assert compare_word_sets(result, [['a'], ['b']])

test_loop_in_another_branch_1a_accept(R) :- pawel(loop_in_another_branch_1a, A), accept(A, [a | R]).
%py assert compare_word_sets(result, [[]])
test_loop_in_another_branch_1b_accept(R) :- pawel(loop_in_another_branch_1b, A), accept(A, [b | R]).
%py assert compare_word_sets(result, [[]])

%timeout 1000
% test_loop_in_another_branch_2a_accept(R) :- pawel(loop_in_another_branch_2a, A), accept(A, [_ | [a | R]]).
% %py assert compare_word_sets(result, [[]])
test_loop_in_another_branch_2a_accept2(R) :- pawel(loop_in_another_branch_2a, A), accept(A, R).
%py assert contains_words(result, [['a', 'a'], ['b'], ['b', 'b'], ['b', 'b', 'b']])
% test_loop_in_another_branch_2a_accept3(R) :- pawel(loop_in_another_branch_2a, A), accept(A, [_ | R]).
% %py assert contains_words(result, [[], ['b'], ['b', 'b']])
% test_loop_in_another_branch_2b_accept(R) :- pawel(loop_in_another_branch_2b, A), accept(A, [_ | [b | R]]).
% %py assert compare_word_sets(result, [[]])
test_loop_in_another_branch_2b_accept2(R) :- pawel(loop_in_another_branch_2b, A), accept(A, R).
%py assert contains_words(result, [['b', 'b'], ['a'], ['a', 'a'], ['a', 'a', 'a']])
% test_loop_in_another_branch_2b_accept3(R) :- pawel(loop_in_another_branch_2b, A), accept(A, [_ | R]).
% %py assert contains_words(result, [[], ['a'], ['a', 'a']])
