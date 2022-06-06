% TODO wszystkie funkcje z wykorzystaniem member mogłyby byc zaimplementowane
% dzięki wykorzystaniu wyszukiwania binarnego i uporządkowanych list.
% obecnie mają złożoność O(n^2) w większości.

% https://stackoverflow.com/questions/18337235/can-you-write-between-3-in-pure-prolog
bet(N, M, K) :- N =< M, K = N.
bet(N, M, K) :- N < M, N1 is N + 1, bet(N1, M, K).

% alphabet(+Transitions, ?Alphabet, ?SizeOfAlphabet)
alphabet(T, A, N) :- alphabet(T, puste, A, 0, N).
alphabet([], A, A, N, N).
alphabet([fp(_, C, _) | L], A0, A, N0, N) :- 
    (
        existsBST(A0, C) ->

        alphabet(L, A0, A, N0, N);

        insertBST(A0, C, A1),
        N1 is N0 + 1, 
        alphabet(L, A1, A, N1, N)
    ). 

% createTransMap(+TransitionList, +DeadStates, -TransitionsMap, -SizeOfMap)
createTransMap(T, D, S, N) :- createTransMap(T, D, puste, S, 0, N).
createTransMap([], _, S, S, N, N).
createTransMap([fp(State, _, _) | L], D,  S0, S, N0, N) :- 
    (   
        \+ existsMap(S0, State), \+ existsBST(D, State) ->
        
        N1 is N0 + 1, 
        insertBST(S0, entry(State, []), S1),
        createTransMap(L, D, S1, S, N1, N);

        createTransMap(L, D, S0, S, N0, N)
   ). 


% destinationsCorrect(+Transitions, +TransitionMap)
% Checks if transition goals are in the TransitionMap. 
destinationsCorrect([], _).
destinationsCorrect([fp(_, _, X) | L], T) :- 
    existsMap(T, X),
    destinationsCorrect(L, T).

insertBST(puste, X, wezel(puste, X, puste)).
insertBST(wezel(L, W, P), X, wezel(L1, W, P)) :-
  X @< W,
  !,
  insertBST(L, X, L1).
insertBST(wezel(L, W, P), X, wezel(L, W, P1)) :-
  X @> W,
  insertBST(P, X, P1).

% getMap(+Map, +Key, -Value).
getMap(wezel(_, entry(K, V), _), K, V) :- !.
getMap(wezel(L, entry(K2, _), _), K, V) :-
    K @< K2,
    % ODCIECIE HERE
    !,
    getMap(L, K, V).
getMap(wezel(_, entry(K2, _), R), K, V) :-
    K @>  K2,
    getMap(R, K, V).

% setMap(+Key, +Value, +Map, -NewMap)
setMap(K, V, wezel(L, entry(K, _), R), wezel(L, entry(K, V), R)) :- !.
setMap(K, V, wezel(L, entry(K2, V2), R), wezel(L2, entry(K2, V2), R)) :-
    K @< K2,
    !,
    setMap(K, V, L, L2).
setMap(K, V, wezel(L, entry(K2, V2), R), wezel(L, entry(K2, V2), R2)) :-
    K @> K2,
    setMap(K, V, R, R2).

% createBSTMap(+Keys, +InitialNodeValue, -TreeMap).
createBSTMap(S, InitVal, M) :-
    createBSTMap(S, InitVal, puste, M).
createBSTMap([], _, Map, Map).
createBSTMap([ST | States], InitVal, Acc1, Map) :-
    insertBST(Acc1, entry(ST, InitVal), Acc2),
    createBSTMap(States, InitVal, Acc2, Map).

% existsBST(+BST, +Value).
existsBST(wezel(_, V, _), V) :- !.
existsBST(wezel(L, V1, R), V) :-
    (
        V @< V1 ->
        
        existsBST(L, V);
        
        existsBST(R, V)

    ).

% bstToList(+Tree, -List)
bstToList(T, L) :- bstToList(T, [], L).
bstToList(puste, A, A).
bstToList(wezel(L, W, R), A, K) :-
  bstToList(R, A, K1),
  bstToList(L, [W | K1], K).

% listToBST(+List, -Tree)
listToBST(L, T) :-
    listToBST(L, puste, T).
listToBST([], T, T).
listToBST([X | L], T0, T) :-
    insertBST(T0, X, T1),
    listToBST(L, T1, T).

% insertAllTransitions(+TransitionList, +DeadStates, 
%                      +TransMap (indexed by states), 
%                      -TransMap after adding all transitions).
% Function adds all transitions in TransitionList (first argument)
% to empty TransMap.
% While doing that, checks whether TransitionList contains duplicates.
insertAllTransitions([], _, Map, Map). 
insertAllTransitions([fp(State, X, DestState) | TransLeft], D, Map0, Map) :-
    (
        \+ existsBST(D, DestState), \+ existsBST(D, State) ->
        
        getMap(Map0, State, StateTransitions),
        \+ member(trans(X, _), StateTransitions),
        setMap(State, [trans(X, DestState) | StateTransitions], Map0, Map1),
        insertAllTransitions(TransLeft, D, Map1, Map);
        
        insertAllTransitions(TransLeft, D, Map0, Map)
                
    ).

% existsMap(+state, +transMap):
existsMap(Map, State) :-
    getMap(Map, State,  _).

% allStatesExist(+States, +TransMap)
allStatesExist([], _).
allStatesExist([S | States], D) :-
    existsMap(D, S),
    allStatesExist(States, D).

debug(X) :-
    write(X), write("\n").


% TODO czy musimy sprawdzać, że nie ma duplikatów w F.
correct(dfa(TransList, Init, FinalList), 
    aut(Alphabet, 
        TransMapOriginal, 
        TransMap, 
        Init, 
        FinalSet, 
        NRealStates, 
        Infinity)) :- 
    alphabet(TransList, Alphabet, LA),
    % Alphabet cannot be empty.
    Alphabet \= puste,
     
    createTransMap(TransList, puste, TransMap0, NStates),
    
    % Check if destinations are to correct states.
    destinationsCorrect(TransList, TransMap0),
    
    allStatesExist(FinalList, TransMap0),
    existsMap(TransMap0, Init),

    % If function is not partial and there are no transition duplicates
    % the length of transition list must be equal to the product of 
    % the size of alphabet and number of states.
    length(TransList, LT),
    LT is LA * NStates,
  
    listToBST(FinalList, FinalSet),
    
    insertAllTransitions(TransList, puste, TransMap0, TransMapOriginal),
    
    bstToList(TransMap0, StateEntries),
    findAllDeadStates(StateEntries, FinalSet, TransMapOriginal, puste, DeadStates),
    
    % Create TransMap without DeadStates.
    createTransMap(TransList, DeadStates, TransMap2, NRealStates),
    
    % Insert transitions to normal states.
    insertAllTransitions(TransList, DeadStates, TransMap2, TransMap),
    
    infinityCheck(Init, TransMap, Infinity). 

infinityCheck(I, T, inf) :- cycle(I, T), !.
infinityCheck(I, T, notInf) :- \+ cycle(I, T). 

infinityCheck(A, inf) :- cycleAut(A), !.
infinityCheck(A, notInf) :- \+ cycleAut(A). 

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
    existsBST(F, S).
traverseDFS([C | Rest], T, F, CurrState):-
    getMap(T, CurrState, TransList),
    member(trans(C, NextState), TransList),
    traverseDFS(Rest, T, F, NextState).

% findAllDeadStates(+StateEntries, +FinalSet, 
%                   +TransMap, +DeadStatesBefore, 
%                   -DeadStatesAfter).
% Finds all states that are "dead" meaning that there is no path
% from them to the state that is present in the FinalSet.
% Adds them to the DeadStatesBefore, creating DeadStatesAfter.
findAllDeadStates([], _, _, D, D).
findAllDeadStates([entry(CurrState, _) | States], F, T, D0, D) :-
    ( 
        existsBST(D0, CurrState) ->
        % If state is already marked as dead, there is no need to visit it.
        findAllDeadStates(States, F, T, D0, D);
        findAllDeadStatesHelp(CurrState, F, T, D0, D1),
        findAllDeadStates(States, F, T, D1, D)
    ). 

% findAllDeadStatesHelp(+State, +FinalSet, +TransMap, 
% +DeadStatesBefore, -DeadStatesAfter).
% Tries to do dead state traversal (see visitDeadStates documentation)
% starting at the +State.
% If +State is in fact a dead state, DeadStatesAfter
% contain all states visited during the traversal.
% If not, DeadStatesAfter = DeadStatesBefore.
findAllDeadStatesHelp(CurrState, F, T, D0, D) :-
    insertBST(D0, CurrState, D1),
    visitDeadStates([CurrState], F, T, D1, D),
    !.
findAllDeadStatesHelp(CurrState, F, T, D0, D0) :-
    insertBST(D0, CurrState, D1),
    \+ visitDeadStates([CurrState], F, T, D1, _).

% visitDeadStates(+Stack, +FinalSet, +TransMap, +DeadStatesBefore, 
%                 -DeadStatesAfter)
% Succeeds if there is full dfs traversal from the 
% state at the top of the stack that satisfies following rules:
% 1. We do not visit states that are in bst +DeadStatesBefore.
% 2. There is no path from visited nodes to any state that is present
% in +FinalSet.
% If there is such traversal, all visited nodes are added to
% +DeadStatesBefore, creating DeadStatesAfter.
visitDeadStates([], _, _, D, D).
visitDeadStates([CurrState | Stack], F, T, D0, D) :-
    % Continue traversal. 
    % Make sure no state at the stack is among the final states.
    \+ existsBST(F, CurrState),
    getMap(T, CurrState, TransList),
    % Add all states reachable from 
    % CurrState. Mark the added nodes as dead.
    addNextStates(TransList, Stack, StackAfter, D0, D2),
    visitDeadStates(StackAfter, F, T, D2, D).

cycleAut(aut(_, _, T, I, _, _, _)) :- cycle(I, T).

cycle(I, T) :-
    cycle(I, puste, T). 

% cycle(+CurrentState, +VisitedNodes +TransList).
% Predicate meaning that there is a path from CurrentState that
% reaches a node in VisitedNodes.
cycle(CurrState, V, _) :-
    existsBST(V, CurrState),
    !.
cycle(CurrState, V, T) :-
    insertBST(V, CurrState, V1),
    getMap(T, CurrState, TransList),
    member(trans(_, NextState), TransList),
    cycle(NextState, V1, T),
    !. % TODO Jeżeli znajdziemy cykl po wybraniu stanu nie chcemy by próbowało wybierać dalej.

empty(A) :- correct(A, aut(_, _, T, I, F, _, _)),
    \+ emptyDFSstack([I], T, F, wezel(puste, I, puste)).

emptyDFSstack([CurrState | _], _, F, _) :-
    existsBST(F, CurrState).

emptyDFSstack([CurrState | Stack0], T, F, V0) :-
    getMap(T, CurrState, TransList),
    addNextStates(TransList, Stack0, Stack1, V0, V1),
    emptyDFSstack(Stack1, T, F, V1).

% addNextStates(+TranList, +StackBefore, ?StackAfter, +VisitedBefore, ?VisitedAfter)
addNextStates([], S, S, V, V).
addNextStates([trans(_, NextState) | TL], S0, S, V0, V) :-
    ( 
        existsBST(V0, NextState) -> 
        addNextStates(TL, S0, S, V0, V);
        insertBST(V0, NextState, V1),
        addNextStates(TL, [NextState | S0], S, V1, V)
    ).

% cartProduct(+X, +Y, ?L).
cartProduct(X, Y, L) :- cartProductHelp(X, Y, L-[]).
cartProductHelp([], _, L-L).
cartProductHelp([E | L1], L2, AFTER2-BEFORE) :-
    cartHandleHelp(L2, E, AFTER1-BEFORE),
    cartProductHelp(L1, L2, AFTER2-AFTER1).

cartHandleHelp([], _, L-L).
cartHandleHelp([H | T], X, [prod(X, H)| R]-L) :- 
    cartHandleHelp(T, X, R-L).

prodStateTrans([], _, _, []). 
prodStateTrans([X | A], T1, T2, [trans(X, prod(Y1, Y2)) | TPROD]) :-
    member(trans(X, Y1), T1),
    member(trans(X, Y2), T2),
    !, % Cut because there can be only one 
       % members of T1 and T2 with X as first tuple element.
    prodStateTrans(A, T1, T2, TPROD).

addAllProductTrans([], _, _, _, D, D).
addAllProductTrans([prod(S1, S2) | SPROD], A, D1, D2, D0, DPROD) :-
   getMap(D1, S1, T1),
   getMap(D2, S2, T2),
   prodStateTrans(A, T1, T2, TPROD),
   setMap(prod(S1, S2), TPROD, D0, DPROD1),
   addAllProductTrans(SPROD, A, D1, D2, DPROD1, DPROD).

% keysListFromMap(+TreeMap, -KeyList)
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
    bstToList(F1, FL1),
    bstToList(F2, FL2),
    cartProduct(S1, S2, SPROD),
    cartProduct(FL1, FL2, FLPROD),
    createBSTMap(SPROD,  [], TPROD0),
    addAllProductTrans(SPROD, AL, T1, T2, TPROD0, TPROD),
    listToBST(FLPROD, FPROD),
    \+ emptyDFSstack([prod(I1, I2)], TPROD, FPROD, wezel(puste, prod(I1, I2), puste)). 

% complement(+L, +F, -FComplement)
% Creates set of elements from L that are not present in F.
complement(L, F, FC) :- complement(L, F, puste, FC).
complement([], _, FC, FC).
complement([X | L], F, FC0, FC) :-
    ( 
        existsBST(F, X) ->
        complement(L, F, FC0, FC);
        insertBST(FC0, X, FC1),
        complement(L, F, FC1, FC)
    ).

subsetEq(A1, A2) :-
    correct(A1, aut(Alph1, TO1, _, I1, F1, _, _)),
    correct(A2, aut(Alph2, TO2, _, I2, F2, _, _)),
    bstToList(Alph1, AL),
    bstToList(Alph2, AL),
    subsetEq(Alph1, (TO1, I1, F1), (TO2, I2, F2)). 

subsetEq(A, (TO1, I1, F1), (TO2, I2, F2)) :-
    keysListFromMap(TO2, S2),
    complement(S2, F2, FC2),
    % debug(("FC2 = ", FC2)), 
    capEmpty(A, (TO1, I1, F1), (TO2, I2, FC2)).    

equal(A1, A2) :-
    correct(A1, aut(Alph1, TO1, _, I1, F1, _, _)),
    correct(A2, aut(Alph2, TO2, _, I2, F2, _, _)),
    bstToList(Alph1, AL),
    bstToList(Alph2, AL),
    subsetEq(Alph1, (TO2, I2, F2), (TO1, I1, F1)),
    subsetEq(Alph1, (TO1, I1, F1), (TO2, I2, F2)). 
    

% https://www.geeksforgeeks.org/sorted-linked-list-to-balanced-bst/


% Krzysztof Jankowski
% Oczekiwany
% a
% a, a
% b
% b, a
% b, b
% b, b, a
% my_example(k1, dfa([fp(1,a,3), fp(1, b, 2), fp(2, b, 3), fp(2, a, 4), fp(3, a, 4), fp(3, b, 5), fp(4, a, 5), fp(4, b, 5), fp(5, a, 5), fp(5, b, 5)], 1, [2,3,4])).
% my_example(k2, dfa([fp(1,a,3), fp(1, b, 2), fp(2, b, 3), fp(2, a, 4), fp(3, a, 4), fp(3, b, 5), fp(4, a, 5), fp(4, b, 5), fp(5, a, 6), fp(5, b, 6), fp(6, a, 7), fp(6, b, 7), fp(7, a, 5), fp(7, b, 5)], 1, [2,3,4])).
% 
% 
% my_example(a11, dfa([fp(1,a,1),fp(1,b,2),fp(2,a,2),fp(2,b,1)], 1, [2,1])).
% my_example(a12, dfa([fp(x,a,y),fp(x,b,x),fp(y,a,x),fp(y,b,x)], x, [x,y])).
% my_example(a2, dfa([fp(1,a,2),fp(2,b,1),fp(1,b,3),fp(2,a,3),
% fp(3,b,3),fp(3,a,3)], 1, [1])).
% my_example(a3, dfa([fp(0,a,1),fp(1,a,0)], 0, [0])).
% my_example(a4, dfa([fp(x,a,y),fp(y,a,z),fp(z,a,x)], x, [x])).
% my_example(a5, dfa([fp(x,a,y),fp(y,a,z),fp(z,a,zz),fp(zz,a,x)], x, [x])).
% my_example(a6, dfa([fp(1,a,1),fp(1,b,2),fp(2,a,2),fp(2,b,1)], 1, [])).
% my_example(a7, dfa([fp(1,a,1),fp(1,b,2),fp(2,a,2),fp(2,b,1),
% fp(3,b,3),fp(3,a,3)], 1, [3])).
% % bad ones
% my_example(b1, dfa([fp(1,a,1),fp(1,a,1)], 1, [])).
% my_example(b2, dfa([fp(1,a,1),fp(1,a,2)], 1, [])).
% my_example(b3, dfa([fp(1,a,2)], 1, [])).
% my_example(b4, dfa([fp(1,a,1)], 2, [])).
% my_example(b4, dfa([fp(1,a,1)], 1, [1,2])).
% my_example(b5, dfa([], [], [])).
% 
% mTCorrect(X, Z) :- my_example(X, Y), correct(Y, Z).
% mTBadCorrect() :- 
%     member(X, [b1, b2, b3, b4, b5]),
%     mTCorrect(X, _),
%     debug(X).
% mTGoodCorrect() :-
%     member(X, [a11, a12, a2, a3, a4, a5, a6, a7]),
%     \+ mTCorrect(X, _),
%     debug(X).
% mTAllCorrect() :- \+ mTBadCorrect(),
%     \+ mTGoodCorrect().
% 
% mTNotEmpty1() :-
%     member(X, [b1, b2, b3, b4, b5, a11, a12, a2, a3, a4, a5]),
%     my_example(X, XAUT),
%     empty(XAUT),
%     debug(X).
% 
% mTNotEmpty2() :-
%     member(Y, [a6, a7]),
%     my_example(Y, YAUT),
%     \+ empty(YAUT).
% 
% mTEmpty() :-
%     \+ mTNotEmpty1(),
%     \+ mTNotEmpty2().
% 
% mTAccept(X, Z) :- 
%     my_example(X, Y), 
%     accept(Y, Z).
% 
% mTAllInfinite() :-
%     \+ mTPositiveInfinite(),
%     \+ mTNegativeInfinite().
% mTPositiveInfinite() :-
%    member(X, [a11, a12, a2, a3, a4, a5]),
%    \+ mTInfinite(X),
%    debug(X).
% mTNegativeInfinite() :-
%     member(X, [k1, k2]),
%     mTInfinite(X),
%     debug(X).
% mTInfinite(X) :-
%     my_example(X, Y),
%     correct(Y, R),
%     cycleAut(R).
% 
% mTSubset(X, Y) :-
%     my_example(X, XR),
%     my_example(Y, YR),
%     debug(XR),
%     debug(YR),
%     subsetEq(XR, YR).
% mTPositiveSubset() :-
%     member((X, Y), [(a5, a3)]),
%     \+ mTSubset(X, Y),
%     debug((X, Y)).
% mTTrivialPositiveSubset() :-
%     member(X, [a11, a12, a2, a6, a7]),
%     member(Y, [a11, a12]),
%     \+ mTSubset(X, Y),
%     debug((X, Y)).
% mTNegativeSubset() :-
%     member((X, Y), [(a4, a3), (a3, a5), (a4, a5), (a3, a4)]),
%     mTSubset(X, Y),
%     debug((X, Y)).
% mTAllSubset() :-
%     \+ mTPositiveSubset(),
%     \+ mTTrivialPositiveSubset(),
%     \+ mTNegativeSubset().
% 
