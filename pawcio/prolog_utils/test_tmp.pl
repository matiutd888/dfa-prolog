:- consult('test_lib').
:- consult('../tests/automata').
:- consult('../solution').
:- consult('../tests/krzysztof').
:- run_test(test1_correct, test1_correct(V0), [V0], ['result'], 100, 100).
:- run_test(test2_correct, test2_correct(V0), [V0], ['result'], 100, 100).
:- run_test(test_test1_accept, test_test1_accept(V0), [V0], ['result'], 100, 100).
:- run_test(test_test2_accept, test_test2_accept(V0), [V0], ['result'], 100, 100).
:- halt.
