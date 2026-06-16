#residual #PA #calibration

residual = 1 - norm^2

** norm = alpha^2 + beta^2

PA(Polarizer Angle) = 0 에서 alpha = 1, beta = 0 이어야 하므로, residual = 0이어야 한다.



하지만 파장의존성과 noise 때문에 보정이 필요한데

P0, A0(lambda) -> cauchy dispersion과


*   residual = 1 - (a2^2 + b2^2)
    

*   eta = sqrt(a2 ^2 + b2^2) = norm
    

*   alpha = a2/eta, beta = b2/eta


A0 보정 후 -> beta 평균이 flat 하게 0에 가까워짐 -> flat

eta 보정 후 -> alpha 가 전 파장에서 1 -> flat


* PA calibration
  * 1. PA = 0에서 residual test 실시 -> PA, A0, eta
    2. PA=35, PA=-35에서 측정 후 beta (서로 반대), alpha(서로 같음) 데이터를 비교하여 offset 값 계산


    ![[i/2026-06-09_08-31-01.png]]
       -