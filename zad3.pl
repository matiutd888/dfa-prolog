% TODO wszystkie funkcje z wykorzystaniem member mogłyby byc zaimplementowane
% dzięki wykorzystaniu wyszukiwania binarnego i uporządkowanych list.
% obecnie mają złożoność O(n^2) w większości.

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
% notTransition(T, A, S) :- member(A1, A), 
%    member(S1, S),
%    \+member(fp(S1, A1, _), T).

% subList(+l1, +l2)
% Sprawdza, czy każdy element na jednej liście pojawia się na drugiej.
% tutaj można usuwać po znalezieniu
% zakładamy, że l1 nie ma duplikatów.
subList([], _).
subList([X | L], L2) :- member(X, L2), subList(L, L2).

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
    length(A, LA), % tę długość można liczyć przy liczeniu alphabet.
    length(S, LS), % jak wyżej.
    length(T, LT),
    LT is LA * LS,
    checkDestinations(T, S).
    % \+ notTransition(T, A, S).


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
