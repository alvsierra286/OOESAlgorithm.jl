\ENCODING=ISO-8859-1
\Problem name: IloCplex

Minimize
 obj: 12 x1 - 2 x2 + 4 x3 + 7 x4
Subject To
 c1:  - x1 + 3 x5 <= 0
 c2:  x1 - 6 x5 <= 0
 c3:  3 x5 - x2 <= 0
 c4:  - 6 x5 + x2 <= 0
 c5:  - x3 + 4 x6 <= 0
 c6:  x3 - 4.5 x6 <= 0
 c7:  4 x6 - x4 <= 0
 c8:  - 4.5 x6 + x4 <= 0
 c9:  x5 + x6 <= 5
 c10: 3 x1 + 6 x2 - 3 x3 - 5 x4 = 0
 c11: - 15 x1 - 4 x2 - x3 - 2 x4 = 0
Bounds
 0 <= x1 <= 100000000
 0 <= x5 <= 100000000
 0 <= x2 <= 100000000
 0 <= x3 <= 100000000
 0 <= x6 <= 100000000
 0 <= x4 <= 100000000
Generals
 x5  x6 
End
