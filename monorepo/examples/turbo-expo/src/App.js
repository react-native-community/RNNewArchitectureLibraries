import React, { useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';

export function App() {
  const [result, setResult] = useState();

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
