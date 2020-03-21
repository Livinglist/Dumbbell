extension ListHelpers<T> on List<T>{
  void swap(int a, int b){
    T temp = this[b];
    this[b] = this[a];
    this[a] = temp;
  }
}