% TODO wszystkie funkcje z wykorzystaniem member mogłyby byc zaimplementowane
% dzięki wykorzystaniu wyszukiwania binarnego i uporządkowanych list.
% obecnie mają złożoność O(n^2) w większości.




dlugosc(A, X) :- lengthHelp(A, 0, X).
lengthHelp([], X, X).
lengthHelp([_ | L], Y, X) :- 
    Y2 is Y + 1,
    lengthHelp(L, Y2, X). 

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

% alphabet(+Transitions, ?Alphabet)
alphabet(T, A) :- alphabet(T, [], A).
alphabet([], A, A).
alphabet([fp(_, C, _) | L], R, A) :- 
    \+ member(C, R), !, 
    alphabet(L , [C | R], A).
alphabet([fp(_, C, _) | L], R, A) :- 
    member(C, R), 
    alphabet(L , R, A).

% createTransMap(+TransitionList, ?StatesTransitionsMap, ?Len)
createTransMap(T, S, N) :- createTransMap(T, puste, S, 0, N).
createTransMap([], S, S, N, N).
createTransMap([fp(State, _, _) | L], S0, S, N0, N) :- 
    \+ existsMap(State, S0),
    N1 is N0 + 1,
    !, 
    insertBST(S0, entry(State, []), S1),
    createTransMap(L, S1, S, N1, N).
createTransMap([fp(State, _, _) | L], S0, S, N0, N) :- 
    existsMap(State, S0),
    createTransMap(L, S0, S, N0, N).

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
% insertIntoTransBSTMap(fp(ST, X, Y), wezel(L, entry(NextState, T), R), wezel(L2, entry(NST, T), R)) :-
%     ST @< NextState,
%     insertIntoTransBSTMap(fp(ST, X, Y), L, L2).
% insertIntoTransBSTMap(fp(ST, X, Y), wezel(L, entry(NextState, T), R), wezel(L, entry(NST, T), R2)) :-
%     ST @> NextState,
%     insertIntoTransBSTMap(fp(ST, X, Y), R, R2).

insertBST(puste, X, wezel(puste, X, puste)).
insertBST(wezel(L, W, P), X, wezel(L1, W, P)) :-
  X @< W,
  !,
  insertBST(L, X, L1).
insertBST(wezel(L, W, P), X, wezel(L, W, P1)) :-
  X @> W,
  insertBST(P, X, P1).

% getMap(+MAP, +KEY, -VALUE).
getMap(wezel(_, entry(K, V), _), K, V).
getMap(wezel(L, entry(K2, _), _), K, V) :-
    K @< K2,
    % ODCIECIE HERE
    % !,
    getMap(L, K, V).
getMap(wezel(_, entry(K2, _), R), K, V) :-
    K @>  K2,
    getMap(R, K, V).

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
createBSTMap(S, InitVal, M) :-
    createBSTMap(S, InitVal, puste, M).
createBSTMap([], _, Map, Map).
createBSTMap([ST | States], InitVal, Acc1, Map) :-
    insertBST(Acc1, entry(ST, InitVal), Acc2),
    createBSTMap(States, InitVal, Acc2, Map).
% createBST(+Elements, +BST)
createBST(E, T) :-
    createBST(E, puste, T).
createBST([], T, T).
createBST([E | Elements], T0, T) :-
    insertBST(T0, E, T1),
    createBST(Elements, T1, T).

% existsBST(+BST, +Value).
existsBST(wezel(_, V, _), V).
existsBST(wezel(L, V1, _), V) :-
    V @< V1,
    % ODCIECIE HERE
    % !,
    existsBST(L, V).
existsBST(wezel(_, V1, R), V) :-
    V @> V1,
    % ODCIECIE HERE
    % !,
    existsBST(R, V).

bstToList(T, L) :- bstToList(T, [], L).
bstToList(puste, A, A).
bstToList(wezel(L, W, R), A, K) :-
  bstToList(R, A, K1),
  bstToList(L, [W | K1], K).

% bstSize(T, N) :- bstSize(T, 0, N).
% bstSize(puste, N0, N).
% bstSize(wezel(L, _, R), N0, N) :-
%     bstSize(L, _, R)

% insertAllTransitions(+Tranzycje, +pustaMapa, -mapaPoDodaniu).
insertAllTransitions([], Map, Map). 
insertAllTransitions([fp(State, X, DestState) | TransLeft], Map0, Map2) :-
    getMap(Map0, State, StateTransitions),
    setMap(State, [trans(X, DestState) | StateTransitions], Map0, Map1),
    % insertIntoTransBSTMap(X, M0, M1),
    insertAllTransitions(TransLeft, Map1, Map2).

% existsMap(+state, +transMap):
existsMap(State, Map) :-
    getMap(Map, State,  _).

checkIfAllStatesExist([], _).
checkIfAllStatesExist([S | States], D) :-
    existsMap(S, D),
    checkIfAllStatesExist(States, D).

debug(X) :-
    write(X), write("\n").

% TODO czy musimy sprawdzać, że nie ma duplikatów w F.
correct(dfa(TransList, Init, FinalList), 
        aut(Alphabet, TransMap, Init, FinalSet, NStates)) :- 
    alphabet(TransList, Alphabet),
    Alphabet \= [],
    createTransMap(TransList, TransMap0, NStates),

    checkDestinations(TransList, TransMap0),
    
    checkIfAllStatesExist(FinalList, TransMap0),
    existsMap(Init, TransMap0),

    length(Alphabet, LA), % tę długość można liczyć przy liczeniu alphabet.
    length(TransList, LT),
    LT is LA * NStates,
   
    insertAllTransitions(TransList, TransMap0, TransMap),
    
    createBST(FinalList, FinalSet).
    % Funkcja length nie była pokazywana na wykładzie.
    % findAllDeadStates(S,    
    
    % \+ notTransition(T, A, S).
 
infinite(aut(A, T, I, F, N)) :-
    UpperBound is N + N,
    between(N, UpperBound, WordLength),
    length(Word,  WordLength),
    traverseDFS(aut(A, T, I, F, N), [element(I, Word)]).


accept(AUT, X) :- correct(AUT, REP), acceptAut(REP, X).
acceptAut(aut(A, T, I, F, N), X) :- 
    length(X, _),
    traverseDFS(aut(A, T, I, F, N), [element(I, X)]).

traverseDFS(aut(_, _, _, F, _), [element(ST, []) | _]) :-
    existsBST(F, ST),
    !.
traverseDFS(aut(A, T, I, F, N), [element(ST, [Z | REST]) | Q2]) :-
    getMap(T, ST, TransList),
    member(trans(Z, STN), TransList),
    traverseDFS(aut(A, T, I, F, N), [element(STN, REST) | Q2]).

% deadState(+State, +Aut).
% deadState(S, A) :- \+ emptyDFS(A, S, []).
% findAllDeadStates(_, [], []).
% findAllDeadStates(A, [X | SL], [X | DL]) :-
%     deadState(X, A),
%     !,
%     findAllDeadStates(A, SL, DL).
% findAllDeadStates(A, [X | SL], DL) :-
%     \+ deadState(X, A),
%     findAllDeadStates(A, SL, DL).  

empty(A1) :- correct(A1, aut(A, T, I, F, N)),
    \+ emptyDFS(aut(A, T, I, F, N), I, puste).

emptyDFS(aut(_, _, _, F, _), ST, _) :-
    existsBST(F, ST).

% naprawić z użyciem if-then-else.
emptyDFS(aut(A, T, I, F, N), ST, V0) :- 
    insertBST(V0, ST, V1),
    getMap(T, ST, TransList),
    member(trans(_, NextState), TransList),
    \+ existsBST(V1, NextState),
    emptyDFS(aut(A, T, I, F, N), NextState, V1).

% cartProduct(+X, +Y, ?L).
cartProduct(X, Y, L) :- cartProductHelp(X, Y, L-[]).
cartProductHelp([], _, L-L).
cartProductHelp([E | L1], L2, AFTER2-BEFORE) :-
    cartHandleHelp(E, L2, AFTER1-BEFORE),
    cartProductHelp(L1, L2, AFTER2-AFTER1).

cartHandleHelp([], _, L-L).
cartHandleHelp([H | T], X, [prod(X, H)| R]-L) :- 
    cartHandleHelp(T, X, R-L).

% prodStateTrans(A, prod(S1, S2), T1, T2) :-

prodStateTrans([], _, _, _). 
prodStateTrans([X | A], T1, T2, [prod(Y1, Y2) | TPROD]) :-
    member(trans(X, Y1), T1),
    member(trans(X, Y2), T2),
    prodStateTrans(A, T1, T2, TPROD).

addAllProductTrans(_, [], _, _, D, D).
addAllProductTrans(A, [prod(S1, S2) | SPROD], D1, D2, D0, DPROD) :-
   getMap(D1, S1, T1),
   getMap(D2, S2, T2),
   prodStateTrans(A, T1, T2, TPROD),
   setMap(prod(S1, S2), TPROD, D0, DPROD1),
   addAllProductTrans(A, SPROD, D1, D2, DPROD1, DPROD).

% cap(aut(A, S1, D1, I1, F1), aut(A, S2, D2, I2, F2), aut(A, SPROD, DPROD, prod(I1, I2), FPROD)) :-
%     cartProduct(S1, S2, SPROD),
%     write(SPROD), write("\n"),
%     cartProduct(F1, F2, FPROD),
%     write(FPROD), write("\n"),
%     createBSTMap(SPROD,  [], DPROD0),
%     addAllProductTrans(A, SPROD, D1, D2, DPROD0, DPROD).
    

% https://www.geeksforgeeks.org/sorted-linked-list-to-balanced-bst/

% Krzysztof Jankowski
% Oczekiwany
% a
% a, a
% b
% b, a
% b, b
% b, b, a
example(k1, dfa([fp(1,a,3), fp(1, b, 2), fp(2, b, 3), fp(2, a, 4), fp(3, a, 4), fp(3, b, 5), fp(4, a, 5), fp(4, b, 5), fp(5, a, 5), fp(5, b, 5)], 1, [2,3,4])).
example(k2, dfa([fp(1,a,3), fp(1, b, 2), fp(2, b, 3), fp(2, a, 4), fp(3, a, 4), fp(3, b, 5), fp(4, a, 5), fp(4, b, 5), fp(5, a, 6), fp(5, b, 6), fp(6, a, 7), fp(6, b, 7), fp(7, a, 5), fp(7, b, 5)], 1, [2,3,4])).


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

testNotEmpty1() :-
    member(X, [b1, b2, b3, b4, b5, a11, a12, a2, a3, a4, a5]),
    example(X, XAUT),
    empty(XAUT),
    debug(X).

testNotEmpty2() :-
    member(Y, [a6, a7]),
    example(Y, YAUT),
    \+ empty(YAUT).

testEmpty() :-
    \+ testNotEmpty1(),
    \+ testNotEmpty2().

testAccept(X, Z) :- 
    example(X, Y), 
    debug(Y),
    accept(Y, Z).
