% TODO wszystkie funkcje z wykorzystaniem member mogłyby byc zaimplementowane
% dzięki wykorzystaniu wyszukiwania binarnego i uporządkowanych list.
% obecnie mają złożoność O(n^2) w większości.

dlugosc(A, X) :- dlugoscHelp(A, 0, X).
dlugoscHelp([], X, X).
dlugoscHelp([_ | L], Y, X) :- 
    Y2 is Y + 1,
    dlugoscHelp(L, Y2, X). 

% Implementacja kolejki za pomocą listy różnicowej.
initQ(L-L).

closeQ(_-X) :- X = [].

emptyQ(L-L) :- var(L).

pushQ(X, L-L, K) :-
  var(L),
  !,
  K = [X | R]-R.
pushQ(X, L-R, L-K) :-
  nonvar(L),
  var(R),
  R = [X | K].

popQ([A | R]-X, R-X, A) :- var(X).

listOfLength(0, []).
listOfLength(X, [_ | L]) :-
    X > 0,
    X2 is X - 1,
    listOfLength(X2, L).

% alphabet(+przejscia, ?alphabet)
alphabet(F, A) :- alphabet(F, [], A).
alphabet([], A, A).
alphabet([fp(_, C, _) | L], R, A) :- 
    \+ member(C, R), !, 
    alphabet(L , [C | R], A).
alphabet([fp(_, C, _) | L], R, A) :- 
    member(C, R), 
    alphabet(L , R, A).

% states(+przejscia, ?states)
states(F, A) :- states(F, [], A).
states([], A, A).
states([fp(S, _, _) | L], R, A) :- 
    \+ member(S, R), !, 
    states(L , [S | R], A).
states([fp(S, _, _) | L], R, A) :- 
    member(S, R), 
    states(L , R, A).

% notTransition(+transitions, +alphabet, +states)
notTransition(T, A, S) :- member(A1, A), 
   member(S1, S),
   \+ member(fp(S1, A1, _), T).

% subList(+l1, +l2)
% Sprawdza, czy każdy element na jednej liście pojawia się na drugiej.
% tutaj można usuwać po znalezieniu
% zakładamy, że l1 nie ma duplikatów.
subList([], _).
subList([X | L], L2) :- member(X, L2), subList(L, L2).

odwroc(L, R) :- odwroc(L, [], R).
odwroc([], R, R).
odwroc([X | L], Z, R) :- odwroc(L, [X | Z], R).


% checkDestinations(+tranzycje, +stany) - sprawdza, czy 
% cele tranzycji są w stanach.
checkDestinations([], _).
checkDestinations([fp(_, _, X) | L], S) :- 
    member(X, S),
    checkDestinations(L, S).

% checkTransitionDuplicates(+list tranzycji)
checkTransitionDuplicates(T) :- checkTransitionDuplicates(T, []).
checkTransitionDuplicates([], _).
checkTransitionDuplicates([fp(S, A, X) | L], AK) :-
    \+ member(fp(S, A, _), AK),
    checkTransitionDuplicates(L, [fp(S, A, X) | AK]).

% TODO czy musimy sprawdzać, że nie ma duplikatów w F.
correct(dfa(T, B, F), myAutomata(A, S, T, B, F)) :- 
    alphabet(T, A),
    states(T, S),
    subList(F, S),
    member(B, S),
    checkTransitionDuplicates(T),
    %  Funkcja length nie była pokazywana na wykładzie.
    dlugosc(A, LA), % tę długość można liczyć przy liczeniu alphabet.
    dlugosc(S, LS), % jak wyżej.
    dlugosc(T, LT),
    LT is LA * LS,
    checkDestinations(T, S).
    % \+ notTransition(T, A, S).


% findTransition(+ST, +A, +T, ?X)
findTransition(ST, A, [fp(ST, A, Z) | _], Z) :- !.
findTransition(ST, A, [_ | L], X) :- findTransition(ST, A, L, X).
    
% accept(myAutomata(A, S, T, I, F), -X). 
accept(AUT, X) :- correct(AUT, REP), accept2(REP, X).
% accept2(myAutomata(A, S, T, I, F), X) :- traverse(myAutomata(A, S, T, I, F), I, X, [], X).
accept2(myAutomata(A, S, T, I, F), X) :- 
    % usuniecie tych linijek sprawia, że przestaje działać :)
    dlugosc(X, LENGTH),
    listOfLength(LENGTH, L),
    %  initQ(Q),
    %  pushQ(element(I, []), Q, QN),
    % traverseBFS(myAutomata(A, S, T, I, F), [element(I, [], L)], X, X).

    traverseDFS(myAutomata(A, S, T, I, F), [element(I, X)]).
    % traverseBFS(myAutomata(A, S, T, I, F), [element(I, X)]).
    % closeQ(QN).
    
addAllTransitions(Q1, Q1, _, [], _) :- !.
addAllTransitions(Q1, Q3, ST, [fp(ST, Z, STN) | T], L) :- 
    pushQ(element(STN, [Z | L]), Q1, Q2),
    addAllTransitions(Q2, Q3, ST, T, L).
addAllTransitions(Q1, Q3, ST, [_ | T], L) :-
    addAllTransitions(Q1, Q3, ST, T, L).
    
traverseBFS(myAutomata(_, _, _, _, F), [element(ST, []) | _]) :-
    member(ST, F).
traverseBFS(myAutomata(A, S, T, I, F), [element(ST, [Z | REST]) | Q2]) :-
    member(fp(ST, Z, STN), T),
    append(Q2, [element(STN, REST)], Q3),
    traverseBFS(myAutomata(A, S, T, I, F), Q3).

traverseDFS(myAutomata(_, _, _, _, F), [element(ST, []) | _]) :-
    member(ST, F).
traverseDFS(myAutomata(A, S, T, I, F), [element(ST, [Z | REST]) | Q2]) :-
    member(fp(ST, Z, STN), T),
    traverseDFS(myAutomata(A, S, T, I, F), [element(STN, REST) | Q2]).

traverse(myAutomata(_, _, _, _, F), ST, X, REVX, []) :- 
    member(ST, F),
    odwroc(X, REVX).
traverse(myAutomata(A, S, T, I, F), ST, X, AK, [_ | LEN]) :-
   traverse(myAutomata(A, S, T, I, F), ST2, X, [Z | AK], LEN),
   member(fp(ST, Z, ST2), T).

% I need to implement bfs traverse as current function is 100% worse!
% It has exponential running time.
% todo bfs traverse
% traversebfs(aut, [(state, word) | Q])
% traverseBFS(aut
% albo bfs z akumulatorem
% traverse(aut, begginingState, [], X)
% traverse(aut, begginingState, [], 

example(a11, dfa([fp(1,a,1),fp(1,b,2),fp(2,a,2),fp(2,b,1)], 1, [2,1])).
example(a12, dfa([fp(x,a,y),fp(x,b,x),fp(y,a,x),fp(y,b,x)], x, [x,y])).
example(a2, dfa([fp(1,a,2),fp(2,b,1),fp(1,b,3),fp(2,a,3),
fp(3,b,3),fp(3,a,3)], 1, [1])).
example(a3, dfa([fp(0,a,1),fp(1,a,0)], 0, [0])).
example(a4, dfa([fp(x,a,y),fp(y,a,z),fp(z,a,x)], x, [x])).
example(a5, dfa([fp(x,a,y),fp(y,a,z),fp(z,a,zz),fp(zz,a,x)], x, [x])).
example(a6, dfa([fp(1,a,1),fp(1,b,2),fp(2,a,2),fp(2,b,1)], 1, [])).
example(a7, dfa([fp(1,a,1),fp(1,b,2),fp(2,a,2),fp(2,b,1),
fp(3,b,3),fp(3,a,3)], 1, [3])).
% bad ones
example(b1, dfa([fp(1,a,1),fp(1,a,1)], 1, [])).
example(b2, dfa([fp(1,a,1),fp(1,a,2)], 1, [])).
example(b3, dfa([fp(1,a,2)], 1, [])).
example(b4, dfa([fp(1,a,1)], 2, [])).
example(b4, dfa([fp(1,a,1)], 1, [1,2])).
example(b5, dfa([], [], [])).


testCorrect(X, Z) :- example(X, Y), correct(Y, Z).
testBadCorrect() :- 
    member(X, [b1, b2, b3, b4, b5]),
    testCorrect(X, _).
testGoodCorrect() :-
    member(X, [a11, a12, a2, a3, a4, a5, a6, a7]),
    \+ testCorrect(X, _).
testAllCorrect() :- \+ testBadCorrect(),
    \+ testGoodCorrect().

testAccept(X, Z) :- example(X, Y), accept(Y, Z).
