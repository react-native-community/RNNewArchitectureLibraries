import React, { useEffect, useState } from 'react';
import { StyleSheet, Text, View } from 'react-native';
// import { multiply, startListening } from 'react-native-turbo-monorepo';

export function App() {
  const [result, setResult] = useState();

  // useEffect(() => {
  //   const subscribe = startListening((event) => {
  //     console.log('event', event);
  //   });
  //   multiply(3, 7).then(setResult);
  //
  //   return () => {
  //     subscribe.remove();
  //   };
  // }, []);

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
