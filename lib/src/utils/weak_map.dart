class WeakMap<K, V> {
  final Map<K, V> _map;
  Expando _expando;

  WeakMap()
      : _map = {},
        _expando = Expando();

  static bool _allowedInExpando(Object? value) =>
      value is! String && value is! num && value is! bool && value != null;

  void operator []=(K key, V value) => add(key: key, value: value);

  V? operator [](K key) => get(key);

  void add({required K key,  V? value}) {
    if (_allowedInExpando(key)) {
      _expando[key!] = value;
    } else {
      assert(value != null, 'Map<K, V> not allow null value');
      _map[key] = value!;
    }
  }

  bool contains(K key) => get(key) != null;

  V? get(K key) {
    if(_map.containsKey(key)){
      return _map[key];
    }else{
      if(_allowedInExpando(key)){
        final value = _expando[key!];
        if(value != null) {
          return value as V;
        }
      }
    }
    return null;
  }

  V getOrThrow(K key) {
    if (_map.containsKey(key)) {
      return _map[key] as V;
    } else {
      if (_allowedInExpando(key)) {
        return _expando[key!] as V;
      } else {
        throw StateError('No value for key.');
      }
    }
  }

  void remove(K key) {
    _map.remove(key);

    if (_allowedInExpando(key)) {
      _expando[key!] = null;
    }
  }

  void clear() {
    _map.clear();
    _expando = Expando();
  }
}
