export function compatibility(me, peer) {
  const theirs = new Set((peer.modules || []).map(x => x.toLowerCase()));
  const modules = (me.modules || []).filter(x => theirs.has(x.toLowerCase())).length;
  const moduleScore = modules / Math.max(1, (me.modules || []).length) * 75;
  const styleScore = me.style && peer.style && me.style === peer.style ? 25 : 0;
  return Math.round(moduleScore + styleScore);
}

export function filterBuddies(peers, query) {
  const q = query.trim().toLowerCase();
  if (!q) return peers;
  return peers.filter(peer => peer.name.toLowerCase().includes(q) || (peer.modules || []).some(module => module.toLowerCase().includes(q)));
}
