double pagePadding(double width) {
  if (width >= 1100) return 28;
  if (width >= 720) return 22;
  return 16;
}

int gridColumns(double width) {
  if (width >= 1100) return 4;
  if (width >= 720) return 3;
  return 2;
}
