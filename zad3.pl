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
    \+ member(S, R), 
    !, 
    states(L , [S | R], A).
states([fp(S, _, _) | L], R, A) :- 
    member(S, R), 
    states(L , R, A).

% notTransition(+transitions, +alphabet, +states)
% notTransition(T, A, S) :- member(A1, A), 
%    member(S1, S),
%    \+ member(fp(S1, A1, _), T).

odwroc(L, R) :- odwroc(L, [], R).
odwroc([], R, R).
odwroc([X | L], Z, R) :- odwroc(L, [X | Z], R).


% checkDestinations(+tranzycje, +stany) - sprawdza, czy 
% cele tranzycji są w stanach.
checkDestinations([], _).
checkDestinations([fp(_, _, X) | L], D) :- 
    existsMap(X, D),
    checkDestinations(L, D).

% checkTransitionDuplicates(+list tranzycji)
% checkTransitionDuplicates(T) :- checkTransitionDuplicates(T, []).
% checkTransitionDuplicates([], _).
% checkTransitionDuplicates([fp(S, A, X) | L], AK) :-
%     \+ member(fp(S, A, _), AK),
%     checkTransitionDuplicates(L, [fp(S, A, X) | AK]).

% Nie usuwać, może się kiedyś przydać.
% insertIntoTransBSTMap(fp(ST, X, Y), wezel(L, entry(ST, TS), R), wezel(L, entry(ST, [trans(X, Y) | TS]), R)) :-
%     \+ member(trans(X, Y), TS).
% insertIntoTransBSTMap(fp(ST, X, Y), wezel(L, entry(NST, T), R), wezel(L2, entry(NST, T), R)) :-
%     ST @< NST,
%     insertIntoTransBSTMap(fp(ST, X, Y), L, L2).
% insertIntoTransBSTMap(fp(ST, X, Y), wezel(L, entry(NST, T), R), wezel(L, entry(NST, T), R2)) :-
%     ST @> NST,
%     insertIntoTransBSTMap(fp(ST, X, Y), R, R2).

insertBST(puste, X, wezel(puste, X, puste)).
insertBST(wezel(L, W, P), X, wezel(L1, W, P)) :-
  X @=< W,
  !,
  insertBST(L, X, L1).
insertBST(wezel(L, W, P), X, wezel(L, W, P1)) :-
  X @> W,
  insertBST(P, X, P1).

% getMap(+KEY, MAP, -VALUE).
getMap(K, wezel(_, entry(K, V), _), V).
getMap(K, wezel(L, entry(K2, _), _), V) :-
    K @< K2,
    % ODCIECIE HERE
    % !,
    getMap(K, L, V).
getMap(K, wezel(_, entry(K2, _), R), V) :-
    K @>  K2,
    getMap(K, R, V).

setMap(K, V, wezel(L, entry(K, _), R), wezel(L, entry(K, V), R)).
setMap(K, V, wezel(L, entry(K2, V2), R), wezel(L2, entry(K2, V2), R)) :-
    K @< K2,
    % ODCIECIE HERE
    % !,
    setMap(K, V, L, L2).
setMap(K, V, wezel(L, entry(K2, V2), R), wezel(L, entry(K2, V2), R2)) :-
    K @> K2,
    setMap(K, V, R, R2).

% createBSTMap(+KEYS, -newMap, +initial value).
createBSTMap(S, N, V0) :-
    createBSTMap(S, puste, N, V0).
createBSTMap([], D, D, _).
createBSTMap([ST | S], A, D, V0) :-
    insertBST(A, entry(ST, V0), D0),
    createBSTMap(S, D0, D, V0).

% insertAllTransitions(+Tranzycje, +pustaMapa, -mapaPoDodaniu).
insertAllTransitions([], M, M). 
insertAllTransitions([fp(ST, X, ST2) | T], M0, M2) :-
    getMap(ST, M0, TS),
    setMap(ST, [trans(X, ST2) | TS], M0, M1),
    % insertIntoTransBSTMap(X, M0, M1),
    insertAllTransitions(T, M1, M2).

% existsMap(+state, +transMap):
existsMap(ST, D) :-
    getMap(ST, D, _).

checkIfAllStatesExist([], _).
checkIfAllStatesExist([ST | S], D) :-
    existsMap(ST, D),
    checkIfAllStatesExist(S, D).

% TODO czy musimy sprawdzać, że nie ma duplikatów w F.
correct(dfa(T, I, F), aut(A, S, D2, I, F)) :- 
    alphabet(T, A),
    A \= [],
    states(T, S),
    createBSTMap(S, D1, []),
    checkIfAllStatesExist(F, D1),
    existsMap(I, D1),
    insertAllTransitions(T, D1, D2),
    % Funkcja length nie była pokazywana na wykładzie.
    dlugosc(A, LA), % tę długość można liczyć przy liczeniu alphabet.
    dlugosc(S, LS), % jak wyżej.
    dlugosc(T, LT),
    LT is LA * LS,
    checkDestinations(T, D2).
    % \+ notTransition(T, A, S).

% accept(aut(A, S, T, I, F), -X). 
accept(AUT, X) :- correct(AUT, REP), acceptAut(REP, X).
acceptAut(aut(A, S, D, I, F), X) :- 
    % usuniecie tych linijek sprawia, że przestaje działać :) TODO
    dlugosc(X, _),
    %  initQ(Q),
    %  pushQ(element(I, []), Q, QN),
    % traverseBFS(aut(A, S, T, I, F), [element(I, [], L)], X, X).

    traverseDFS(aut(A, S, D, I, F), [element(I, X)]).
    % traverseBFS(aut(A, S, T, I, F), [element(I, X)]).
    % closeQ(QN).

% traverseBFS(aut(_, _, _, _, F), [element(ST, []) | _]) :-
%     member(ST, F),
%     !.
% traverseBFS(aut(A, S, T, I, F), [element(ST, [Z | REST]) | Q2]) :-
%     member(fp(ST, Z, STN), T),
%     append(Q2, [element(STN, REST)], Q3),
%     traverseBFS(aut(A, S, T, I, F), Q3).

traverseDFS(aut(_, _, _, _, F), [element(ST, []) | _]) :-
    member(ST, F),
    !.
traverseDFS(aut(A, S, D, I, F), [element(ST, [Z | REST]) | Q2]) :-
    % member(fp(ST, Z, STN), T),
    getMap(ST, D, T),
    member(trans(Z, STN), T),
    traverseDFS(aut(A, S, D, I, F), [element(STN, REST) | Q2]).

empty(A1) :- correct(A1, aut(A, S, D, I, F)),
   \+ emptyDFS(aut(A, S, D, I, F), I, []).

emptyDFS(aut(_, _, _, _, F), ST, _) :-
    member(ST, F).

emptyDFS(aut(A, S, D, I, F), ST, V) :- 
    V2 = [ST | V],
    getMap(ST, D, T),
    member(trans(_, NST), T),
    \+ member(NST, V2),
    emptyDFS(aut(A, S, D, I, F), NST, V2).

% cartProduct(+X, +Y, ?L).
cartProduct(X, Y, L) :- cartProductHelp(X, Y, L -[]).

cartProductHelp([],_,L-L).
cartProductHelp([E | L1], L2, AFTER2-BEFORE) :-
    cartHandleHelp(E, L2, AFTER1-BEFORE),
    cartProductHelp(L1, L2, AFTER2-AFTER1).

cartHandleHelp(_,[], L - L).
cartHandleHelp(X, [H | T], [product(X, H)| R] - L):- cartHelp(X, T, R - L).


% cap(aut(A, S1, T1, I1, F1), aut(A, S2, T2, I2, F2)) :-
%    cartProduct(S1, S2, SPROD),
        
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
