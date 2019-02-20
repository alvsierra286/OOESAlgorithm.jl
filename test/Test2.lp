\ENCODING=ISO-8859-1
\Problem name: IloCplex

Minimize
 obj: + 12 x1 + 2 x2
Subject To
 c1: x2 <= 3
 c2: 3 x1 - x2 <= 6
 c3: 3 x1 + x2 = 0
 c4: - x1 - 2 x2 = 0
Bounds
 0 <= x1 <= 100000000
 0 <= x2 <= 100000000

End
