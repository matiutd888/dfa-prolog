% Examples from the task content.
% See automata/examples.txt for the tests.

%py expect_single_solution()
test1 :- example(a11, A), example(a12, B), equal(A, B).
test2 :- example(a2, A), example(a11, B), subsetEq(A, B).
test3 :- example(a5, A), example(a3, B), subsetEq(A, B).
test4 :- example(a6, A), empty(A).
test5 :- example(a7, A), empty(A).
test6 :- example(a2, A), accept(A, []).
test7 :- example(a2, A), accept(A, [a,b]).
test8 :- example(a2, A), accept(A, [a,b,a,b]).

%py expect_fail()
test9_b1 :- example(b1, A), correct(A, _).
test9_b2 :- example(b2, A), correct(A, _).
test9_b3 :- example(b3, A), correct(A, _).
test9_b4 :- example(b4, A), correct(A, _).
test9_b5 :- example(b5, A), correct(A, _).
test10 :- example(a2, A), empty(A).
test11 :- example(a3, A), example(a4, B), equal(A, B).
test12 :- example(a4, A), example(a3, B), subsetEq(A, B).
test13 :- example(a2, A), accept(A, [a]).

%py expect_success()

test14([X,Y,Z]) :- example(a11, A), accept(A, [X,Y,Z]).
/*py
import itertools
assert compare_word_sets(result, itertools.product(['a', 'b'], repeat=3))
*/

test15(Var) :- example(a11, A), accept(A, Var).
%%py print(result)
%py assert contains_words(result, [['a', 'b'], ['b', 'a', 'b']])


% Additional tests.
%py expect_single_solution()
test_a11_correct(S) :- example(a11, A), correct(A, S).
test_a12_correct(S) :- example(a11, A), correct(A, S).
test_a2_correct(S) :- example(a11, A), correct(A, S).
test_a3_correct(S) :- example(a11, A), correct(A, S).
test_a4_correct(S) :- example(a11, A), correct(A, S).
test_a5_correct(S) :- example(a11, A), correct(A, S).
test_a6_correct(S) :- example(a11, A), correct(A, S).

%py expect_success()
test_a11_not_empty :- example(a11, A), \+ empty(A).
test_a12_not_empty :- example(a12, A), \+ empty(A).
test_a2_not_empty :- example(a2, A), \+ empty(A).
test_a3_not_empty :- example(a3, A), \+ empty(A).
test_a4_not_empty :- example(a4, A), \+ empty(A).
test_a5_not_empty :- example(a5, A), \+ empty(A).
