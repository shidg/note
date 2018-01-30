#! /usr/local/python3/bin/python3
# -*- coding: utf-8 -*-#
alien_0 = {'color': 'green','points': 5}
alien_1 = {'color': 'yellow','points': 10}
alien_2 = {'color': 'red','points': 15}
alien_3 = {'color': 'blue','points': 20}

aliens = []
for alien_number in range(30):
    new_alien = {'color': 'green','points:': 5,'speed': 'slow'}
    aliens.append(new_alien)

for alien in aliens[:5]:
    print(alien)
print("...")

print("Total number of aliens:" + str(len(aliens)))

for alien in aliens[:3]:
    if alien['color'] == 'green':
        alien['color'] = 'yellow'
        alien['speed'] = 'medium'
        alien['points'] = 10

for alien in aliens[:3]:
    print(alien)
