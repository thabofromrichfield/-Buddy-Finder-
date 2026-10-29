import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';
const root=process.cwd(),types={'.html':'text/html; charset=utf-8','.css':'text/css; charset=utf-8','.js':'text/javascript; charset=utf-8'};
createServer(async(req,res)=>{try{const pathname=decodeURIComponent(new URL(req.url,'http://localhost').pathname);const file=normalize(join(root,pathname==='/'?'index.html':pathname));if(!file.startsWith(root)){res.writeHead(403).end('Forbidden');return}const body=await readFile(file);res.writeHead(200,{'content-type':types[extname(file)]||'application/octet-stream'});res.end(body)}catch{res.writeHead(404).end('Not found')}}).listen(process.env.PORT||4173,()=>console.log(`Buddy Finder running at http://localhost:${process.env.PORT||4173}`));
