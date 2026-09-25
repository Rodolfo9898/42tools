import { useEffect } from 'react';
import { Platform } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import * as NavigationBar from 'expo-navigation-bar';

import AppRoot from './src/frontend/AppRoot';

export default function App() {
  useEffect(() => {
    if (Platform.OS === 'android') {
      NavigationBar.setVisibilityAsync('hidden');
      NavigationBar.setBehaviorAsync('overlay-swipe');
    }
  }, []);

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <AppRoot />
    </GestureHandlerRootView>
  );
}
