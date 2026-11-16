/// Veces guardadas que el niño ha vuelto a bajar del nivel donde se atasca
/// (HU-034 R4). Lo guardado antes de HU-034 no tiene estos campos, y un par
/// incompleto o negativo se lee como «sin atascar» en vez de romper la lectura.
int stuckFallsOrZero(int? stuckLevel, int? stuckFalls) =>
    stuckLevel == null || stuckFalls == null || stuckFalls <= 0 ? 0 : stuckFalls;
