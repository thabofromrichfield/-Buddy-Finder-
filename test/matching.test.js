import test from 'node:test';
import assert from 'node:assert/strict';
import { compatibility, filterBuddies } from '../src/matching.js';

test('ranks peers higher when modules and study style overlap', () => {
  const me = { modules: ['BIO101', 'CHEM102'], style: 'group' };
  const strong = { modules: ['BIO101', 'CHEM102'], style: 'group' };
  const weak = { modules: ['MATH101'], style: 'solo' };
  assert.ok(compatibility(me, strong) > compatibility(me, weak));
});

test('filters buddies by case-insensitive module or name query', () => {
  const peers = [{ name: 'Ava', modules: ['BIO101'] }, { name: 'Noah', modules: ['MATH101'] }];
  assert.deepEqual(filterBuddies(peers, 'bio'), [peers[0]]);
  assert.deepEqual(filterBuddies(peers, 'NOAH'), [peers[1]]);
});
