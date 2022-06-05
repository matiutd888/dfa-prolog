% TODO wszystkie funkcje z wykorzystaniem member mogłyby byc zaimplementowane
% dzięki wykorzystaniu wyszukiwania binarnego i uporządkowanych list.
% obecnie mają złożoność O(n^2) w większości.

% https://stackoverflow.com/questions/18337235/can-you-write-between-3-in-pure-prolog
bet(N, M, K) :- N =< M, K = N.
bet(N, M, K) :- N < M, N1 is N + 1, bet(N1, M, K).

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

% alphabet(+Transitions, ?Alphabet, ?SizeOfAlphabet)
alphabet(T, A, N) :- alphabet(T, puste, A, 0, N).
alphabet([], A, A, N, N).
alphabet([fp(_, C, _) | L], A0, A, N0, N) :- 
    \+ existsBST(A0, C), 
    !,
    insertBST(A0, C, A1),
    N1 is N0 + 1, 
    alphabet(L, A1, A, N1, N).
alphabet([fp(_, C, _) | L], A0, A, N0, N) :- 
    existsBST(A0, C), 
    alphabet(L, A0, A, N0, N).

% createTransMap(+TransitionList, +DeadStates, ?StatesTransitionsMap, ?Len)
createTransMap(T, D, S, N) :- createTransMap(T, D, puste, S, 0, N).
createTransMap([], _, S, S, N, N).
createTransMap([fp(State, _, _) | L], D, S0, S, N0, N) :- 
    existsMap(S0, State),
    !,
    createTransMap(L, D, S0, S, N0, N).
createTransMap([fp(State, _, _) | L], D, S0, S, N0, N) :- 
    existsBST(D, State),
    !,
    createTransMap(L, D, S0, S, N0, N).
createTransMap([fp(State, _, _) | L], D,  S0, S, N0, N) :- 
    \+ existsMap(S0, State),
    \+ existsBST(D, State),
    N1 is N0 + 1,
    !, 
    insertBST(S0, entry(State, []), S1),
    createTransMap(L, D, S1, S, N1, N).

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
    existsMap(D, X),
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

listToBST(L, D) :-
    listToBST(L, [], D).
listToBST([], D, D).
listToBST([X | L], D0, D) :-
    insertBST(D0, X, D1),
    listToBST(L, D1, D).

% bstSize(T, N) :- bstSize(T, 0, N).
% bstSize(puste, N, N).
% bstSize(wezel(L, _, R), N0, N) :-
%     bstSize(

% insertAllTransitions(+Tranzycje, +DeadStates, +pustaMapa, -mapaPoDodaniu).
insertAllTransitions([], _, Map, Map). 
insertAllTransitions([fp(State, X, DestState) | TransLeft], D, Map0, Map) :-
    \+ existsBST(D, DestState),
    \+ existsBST(D, State),
    % !, % Czerwone odcięcie
    getMap(Map0, State, StateTransitions),
    % TODO to trzeba inaczej
    \+ member(trans(X, _), StateTransitions),
    setMap(State, [trans(X, DestState) | StateTransitions], Map0, Map1),
    insertAllTransitions(TransLeft, D, Map1, Map).
insertAllTransitions([fp(_, _, DestState) | TransLeft], D, Map0, Map) :-
    existsBST(D, DestState),
    insertAllTransitions(TransLeft, D, Map0, Map).
insertAllTransitions([fp(State, _, _) | TransLeft], D, Map0, Map) :-
    existsBST(D, State),
    insertAllTransitions(TransLeft, D, Map0, Map).

% existsMap(+state, +transMap):
existsMap(Map, State) :-
    getMap(Map, State,  _).

checkIfAllStatesExist([], _).
checkIfAllStatesExist([S | States], D) :-
    existsMap(D, S),
    checkIfAllStatesExist(States, D).

debug(X) :-
    write(X), write("\n").

% removeAllDeadTrans(+TransMap, +DeadStates, ?TransMapAfter)
removeAllDeadTrans(puste, _, puste).
removeAllDeadTrans(wezel(L0, entry(S, _), R0), D, wezel(L, entry(S, []), R)) :-
    existsBST(D, S),
    !,
    removeAllDeadTrans(L0, D, L),
    removeAllDeadTrans(R0, D, R).
removeAllDeadTrans(wezel(L0, entry(S, T0), R0), D, wezel(L, entry(S, T), R)) :-
    removeDeadTrans(T0, D, T),
    removeAllDeadTrans(L0, D, L),
    removeAllDeadTrans(R0, D, R).

% removeDeadTrans(+TransList, DeadStates, ?TransListAfter) :-
removeDeadTrans([], _, []).
removeDeadTrans([trans(_, DeadState) | T0], D, T) :-
    existsBST(D, DeadState),
    !, % if then else
    removeDeadTrans(T0, D, T).
removeDeadTrans([trans(A, State) | T0], D, [trans(A, State) | T]) :-
    removeDeadTrans(T0, D, T).

% TODO czy musimy sprawdzać, że nie ma duplikatów w F.
correct(dfa(TransList, Init, FinalList), aut(Alphabet, TransMapOriginal, TransMap, Init, FinalSet, NRealStates, inf)) :- 
    alphabet(TransList, Alphabet, LA),
    Alphabet \= puste,
    
    createTransMap(TransList, puste, TransMap0, NStates),
    
    checkDestinations(TransList, TransMap0),
    checkIfAllStatesExist(FinalList, TransMap0),
    existsMap(TransMap0, Init),

    length(TransList, LT),
    LT is LA * NStates,
  
    createBST(FinalList, FinalSet),
    
    insertAllTransitions(TransList, puste, TransMap0, TransMapOriginal),
    % infinityCheck(aut(Alphabet, TransMap, Init, FinalSet, NStates, _), Infinity),
    
    bstToList(TransMap0, StateEntries),
    findAllDeadStates(StateEntries, FinalSet, TransMapOriginal, puste, DeadStates),
    % debug("DeadStates"),
    % debug(DeadStates), 
    createTransMap(TransList, DeadStates, TransMap2, NRealStates),
    % debug("TransMap"), 
    % debug(TransMap2),
    insertAllTransitions(TransList, DeadStates, TransMap2, TransMap),
    % debug(DeadStates),
    !. % Representation is unequivocal, there is no need to search any further. 


isInfinite(aut(_, T, I, F, N, _)) :-
    UpperBound is N + N,
    between(N, UpperBound, WordLength),
    length(Word, WordLength),
    traverseDFS(Word, T, F, I),
    !. % Important, we want only one success here.

infinityCheck(A, inf) :- isInfinite(A), !.
infinityCheck(A, notInf) :- \+ isInfinite(A). 

accept(Aut, X) :- 
    correct(Aut, Rep), 
    acceptAut(Rep, X).
acceptAut(aut(_, _, T, I, F, _, inf), X) :- 
    length(X, _),
    traverseDFS(X, T, F, I).
acceptAut(aut(_, _, T, I, F, N, notInf), X) :- 
    bet(0, N, XLen),
    length(X, XLen),
    traverseDFS(X, T, F, I).

traverseDFS([], _, F, S) :-
    existsBST(F, S),
    !.
traverseDFS([C | Rest], T, F, CurrState):-
    getMap(T, CurrState, TransList),
    member(trans(C, NextState), TransList),
    traverseDFS(Rest, T, F, NextState).

% findAllDeadStates(+StateEntries, +FinalSet, +TransMap, DeadStatesBefore, DeadStatesAfter).
findAllDeadStates([], _, _, D, D).
findAllDeadStates([entry(CurrState, _) | States], F, T, D0, D) :-
    % write("Checking node "), write(CurrState), write(" currently "), debug(D0),
    % write(" remaining"), write(States), write("\n"),
    \+ existsBST(D0, CurrState),
    !, % if then else
    findAllDeadStatesHelp([CurrState | States], F, T, D0, D).
findAllDeadStates([_ | States], F, T, D0, D) :-
    findAllDeadStates(States, F, T, D0, D).

findAllDeadStatesHelp([CurrState | States], F, T, D0, D) :-
    insertBST(D0, CurrState, D1),
    visitDeadStates([CurrState], F, T, D1, D2),
    !, % zamiast odciecia lepiej użyć if then else.
    findAllDeadStates(States, F, T, D2, D).
findAllDeadStatesHelp([_ | States], F, T, D0, D) :-
    % \+ visitDeadStates([CurrState], F, T, D0, _),
    findAllDeadStates(States, F, T, D0, D).

visitDeadStates([], _, _, D, D).
visitDeadStates([CurrState | Stack], F, T, D0, D) :-
    % write(CurrState), write(Stack), write(" "), write(D0), write("\n"),
    \+ existsBST(F, CurrState),
    getMap(T, CurrState, TransList),
    addNextStates(TransList, Stack, StackAfter, D0, D2),
    % write(CurrState), write(": sucessfully added states "), write(Stack), write("\n"),
    visitDeadStates(StackAfter, F, T, D2, D).

cycleAut(aut(_, T, I, _, _, _)) :- cycle(I, T).

cycle(I, T) :-
    cycle(I, puste, T). 

% Tutaj można bardziej optymalnie (sprawdzać cykl przy dodaniu krawędzi).
cycle(CurrState, V, _) :-
    existsBST(V, CurrState),
    !.
cycle(CurrState, V, T) :-
    insertBST(V, CurrState, V1),
    getMap(T, CurrState, TransList),
    member(trans(_, NextState), TransList),
    cycle(NextState, V1, T),
    !. % Jeżeli znajdziemy cykl po wybraniu stanu nie chcemy by próbowało wybierać dalej.

addNoVisitedCheck([], S, S).
addNoVisitedCheck([trans(_, NextState) | TL], S0, S) :-
    addNoVisitedCheck(TL, [NextState | S0], S).    

empty(A) :- correct(A, aut(_, _, T, I, F, _, _)),
    \+ emptyDFSstack([I], T, F, tree(puste, I, puste)).

emptyDFSstack([CurrState | _], _, F, _) :-
    existsBST(F, CurrState).
emptyDFSstack([CurrState | Stack0], T, F, V0) :-
    getMap(T, CurrState, TransList),
    addNextStates(TransList, Stack0, Stack1, V0, V1),
    emptyDFSstack(Stack1, T, F, V1).

% addNextStates(+TranList, +StackBefore, ?StackAfter, +VisitedBefore, ?VisitedAfter)
addNextStates([], S, S, V, V).
addNextStates([trans(_, NextState) | TL], S0, S, V0, V) :-
    \+ existsBST(V0, NextState),
    !, % if then else
    insertBST(V0, NextState, V1),
    addNextStates(TL, [NextState | S0], S, V1, V).    
addNextStates([trans(_, NextState) | TL], S0, S, V0, V) :-
    existsBST(V0, NextState),
    addNextStates(TL, S0, S, V0, V).    

% cartProduct(+X, +Y, ?L).
cartProduct(X, Y, L) :- cartProductHelp(X, Y, L-[]).
cartProductHelp([], _, L-L).
cartProductHelp([E | L1], L2, AFTER2-BEFORE) :-
    cartHandleHelp(E, L2, AFTER1-BEFORE),
    cartProductHelp(L1, L2, AFTER2-AFTER1).

cartHandleHelp([], _, L-L).
cartHandleHelp([H | T], X, [prod(X, H)| R]-L) :- 
    cartHandleHelp(T, X, R-L).

prodStateTrans([], _, _, _). 
prodStateTrans([X | A], T1, T2, [trans(X, prod(Y1, Y2)) | TPROD]) :-
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

keysListFromMap(T, KL) :-
    bstToList(T, TL),
    keysListFromEntriesList(TL, KL).

% keysListFromEntriesList(+EL, -KL)
keysListFromEntriesList([], []).
keysListFromEntriesList([entry(K, _) | EL], [K | KL]) :-
    keysListFromEntriesList(EL, KL).

capEmpty(A, (T1, I1, F1), (T2, I2, F2)) :-
    bstToList(A, AL),
    keysListFromMap(T1, S1),
    keysListFromMap(T2, S2),
    debug((S1, S2)),
    cartProduct(S1, S2, SPROD),
    debug(("Sprod: ", SPROD)), 
    cartProduct(F1, F2, FPROD),
    createBSTMap(SPROD,  [], TPROD0),
    addAllProductTrans(AL, SPROD, T1, T2, TPROD0, TPROD),
    \+ emptyDFSstack([prod(I1, I2)], TPROD, FPROD, tree(puste, prod(I1, I2), puste)). 

% complement(+L, +F, -FComplement)
% Creates set of elements from L that are not present in F.
complement(L, F, FC) :- complement(L, F, puste, FC).
complement([], _, FC, FC).
complement([X | L], F, FC0, FC) :-
    \+ existsBST(F, X),
    !,
    insertBST(FC0, X, FC1),
    complement(L, F, FC1, FC).
complement([X | L], F, FC0, FC) :-
    existsBST(F, X), % TODO To potrzebne by odciecie było zielone. Nie wiem czy to używać.
    complement(L, F, FC0, FC).

subsetEq(A1, A2) :-
    correct(A1, aut(Alph1, TO1, _, I1, F1, _, _)),
    correct(A2, aut(Alph2, TO2, _, I2, F2, _, _)),
    debug("elo"),
    bstToList(Alph1, AL),
    bstToList(Alph2, AL),
    keysListFromMap(TO2, S2),
    complement(S2, F2, FC2),
    capEmpty(Alph1, (TO1, F1, I1), (TO2, FC2, I2)).    
% https://www.geeksforgeeks.org/sorted-linked-list-to-balanced-bst/


% Krzysztof Jankowski
% Oczekiwany
% a
% a, a
% b
% b, a
% b, b
% b, b, a
my_example(k1, dfa([fp(1,a,3), fp(1, b, 2), fp(2, b, 3), fp(2, a, 4), fp(3, a, 4), fp(3, b, 5), fp(4, a, 5), fp(4, b, 5), fp(5, a, 5), fp(5, b, 5)], 1, [2,3,4])).
my_example(k2, dfa([fp(1,a,3), fp(1, b, 2), fp(2, b, 3), fp(2, a, 4), fp(3, a, 4), fp(3, b, 5), fp(4, a, 5), fp(4, b, 5), fp(5, a, 6), fp(5, b, 6), fp(6, a, 7), fp(6, b, 7), fp(7, a, 5), fp(7, b, 5)], 1, [2,3,4])).


my_example(a11, dfa([fp(1,a,1),fp(1,b,2),fp(2,a,2),fp(2,b,1)], 1, [2,1])).
my_example(a12, dfa([fp(x,a,y),fp(x,b,x),fp(y,a,x),fp(y,b,x)], x, [x,y])).
my_example(a2, dfa([fp(1,a,2),fp(2,b,1),fp(1,b,3),fp(2,a,3),
fp(3,b,3),fp(3,a,3)], 1, [1])).
my_example(a3, dfa([fp(0,a,1),fp(1,a,0)], 0, [0])).
my_example(a4, dfa([fp(x,a,y),fp(y,a,z),fp(z,a,x)], x, [x])).
my_example(a5, dfa([fp(x,a,y),fp(y,a,z),fp(z,a,zz),fp(zz,a,x)], x, [x])).
my_example(a6, dfa([fp(1,a,1),fp(1,b,2),fp(2,a,2),fp(2,b,1)], 1, [])).
my_example(a7, dfa([fp(1,a,1),fp(1,b,2),fp(2,a,2),fp(2,b,1),
fp(3,b,3),fp(3,a,3)], 1, [3])).
% bad ones
my_example(b1, dfa([fp(1,a,1),fp(1,a,1)], 1, [])).
my_example(b2, dfa([fp(1,a,1),fp(1,a,2)], 1, [])).
my_example(b3, dfa([fp(1,a,2)], 1, [])).
my_example(b4, dfa([fp(1,a,1)], 2, [])).
my_example(b4, dfa([fp(1,a,1)], 1, [1,2])).
my_example(b5, dfa([], [], [])).

testCorrect(X, Z) :- my_example(X, Y), correct(Y, Z).
testBadCorrect() :- 
    member(X, [b1, b2, b3, b4, b5]),
    testCorrect(X, _),
    debug(X).
testGoodCorrect() :-
    member(X, [a11, a12, a2, a3, a4, a5, a6, a7]),
    \+ testCorrect(X, _),
    debug(X).
testAllCorrect() :- \+ testBadCorrect(),
    \+ testGoodCorrect().

testNotEmpty1() :-
    member(X, [b1, b2, b3, b4, b5, a11, a12, a2, a3, a4, a5]),
    my_example(X, XAUT),
    empty(XAUT),
    debug(X).

testNotEmpty2() :-
    member(Y, [a6, a7]),
    my_example(Y, YAUT),
    \+ empty(YAUT).

testEmpty() :-
    \+ testNotEmpty1(),
    \+ testNotEmpty2().

testAccept(X, Z) :- 
    my_example(X, Y), 
    accept(Y, Z).

testAllInfinite() :-
    \+ testPositiveInfinite(),
    \+ testNegativeInfinite().
testPositiveInfinite() :-
   member(X, [a11, a12, a2, a3, a4, a5]),
   \+ testInfinite(X).
testNegativeInfinite() :-
    member(X, [k1, k2]),
    testInfinite(X).

testInfinite(X) :-
    my_example(X, Y),
    correct(Y, R),
    isInfinite(R).
