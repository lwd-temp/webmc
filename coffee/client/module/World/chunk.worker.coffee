import {CellTerrain} from './CellTerrain.js'
import {BlockGeo} from './BlockGeo.js'

console.log "CHUNK WORKER STARTED!"

class TerrainManager
	constructor: (options)->
		@cellSize=options.cellSize
		@cellTerrain=new CellTerrain {
			cellSize:@cellSize
		}
		@BlockGeo=new BlockGeo {
			toxelSize:options.toxelSize
			blocksMapping:options.blocksMapping
		}
	genCellGeo: (cellX,cellY,cellZ)->
		_this=@
		positions=[]
		normals=[]
		uvs=[]
		colors=[]
		aoColor=(type)->
			if type is 0
				return [0.9,0.9,0.9]
			else if type is 1
				return [0.7,0.7,0.7]
			else if type is 2
				return [0.5,0.5,0.5]
			else
				return [0.3,0.3,0.3]
		addFace=(type,pos)->
			faceVertex=_this.BlockGeo.genBlockFace type,_this.cellTerrain.getBlock(pos...),pos
			positions.push faceVertex.pos...
			normals.push faceVertex.norm...
			uvs.push faceVertex.uv...
			# _this.cellTerrain.getBlock(pos[0],pos[1],pos[2])
			loaded={}
			for x in [-1..1]
				for y in [-1..1]
					for z in [-1..1]
						if (_this.cellTerrain.getBlock(pos[0]+x, pos[1]+y,pos[2]+z).boundingBox is "block")
							loaded["#{x}:#{y}:#{z}"]=1
						else
							loaded["#{x}:#{y}:#{z}"]=0
			col1=aoColor(0)
			col2=aoColor(0)
			col3=aoColor(0)
			col4=aoColor(0)
			if type is "py"
				col1=aoColor(loaded["1:1:-1"]+loaded["0:1:-1"]+loaded["1:1:0"])
				col2=aoColor(loaded["1:1:1"]+loaded["0:1:1"]+loaded["1:1:0"])
				col3=aoColor(loaded["-1:1:-1"]+loaded["0:1:-1"]+loaded["-1:1:0"])
				col4=aoColor(loaded["-1:1:1"]+loaded["0:1:1"]+loaded["-1:1:0"])
			if type is "ny"
				col2=aoColor(loaded["1:-1:-1"]+loaded["0:-1:-1"]+loaded["1:-1:0"])
				col1=aoColor(loaded["1:-1:1"]+loaded["0:-1:1"]+loaded["1:-1:0"])
				col4=aoColor(loaded["-1:-1:-1"]+loaded["0:-1:-1"]+loaded["-1:-1:0"])
				col3=aoColor(loaded["-1:-1:1"]+loaded["0:-1:1"]+loaded["-1:-1:0"])
			if type is "px"
				col1=aoColor(loaded["-1:-1:0"]+loaded["-1:-1:-1"]+loaded["-1:0:-1"])
				col2=aoColor(loaded["-1:1:0"]+loaded["-1:1:-1"]+loaded["-1:0:-1"])
				col3=aoColor(loaded["-1:-1:0"]+loaded["-1:-1:1"]+loaded["-1:0:1"])
				col4=aoColor(loaded["-1:1:0"]+loaded["-1:1:1"]+loaded["-1:0:1"])
			if type is "nx"
				col3=aoColor(loaded["1:-1:0"]+loaded["1:-1:-1"]+loaded["1:0:-1"])
				col4=aoColor(loaded["1:1:0"]+loaded["1:1:-1"]+loaded["1:0:-1"])
				col1=aoColor(loaded["1:-1:0"]+loaded["1:-1:1"]+loaded["1:0:1"])
				col2=aoColor(loaded["1:1:0"]+loaded["1:1:1"]+loaded["1:0:1"])
			if type is "pz"
				col1=aoColor(loaded["0:-1:1"]+loaded["-1:-1:1"]+loaded["-1:0:1"])
				col2=aoColor(loaded["0:1:1"]+loaded["-1:1:1"]+loaded["-1:0:1"])
				col3=aoColor(loaded["0:-1:1"]+loaded["1:-1:1"]+loaded["1:0:1"])
				col4=aoColor(loaded["0:1:1"]+loaded["1:1:1"]+loaded["1:0:1"])
			if type is "nz"
				col3=aoColor(loaded["0:-1:-1"]+loaded["-1:-1:-1"]+loaded["-1:0:-1"])
				col4=aoColor(loaded["0:1:-1"]+loaded["-1:1:-1"]+loaded["-1:0:-1"])
				col1=aoColor(loaded["0:-1:-1"]+loaded["1:-1:-1"]+loaded["1:0:-1"])
				col2=aoColor(loaded["0:1:-1"]+loaded["1:1:-1"]+loaded["1:0:-1"])

			colors.push col1...,col3...,col2...,col2...,col3...,col4...
			return
		for i in [0..@cellSize-1]
			for j in [0..@cellSize-1]
				for k in [0..@cellSize-1]
					pos=[cellX*@cellSize+i,cellY*@cellSize+j,cellZ*@cellSize+k]
					if @cellTerrain.getBlock(pos...).boundingBox is "block"
						if (@cellTerrain.getBlock(pos[0]+1,pos[1],pos[2]).boundingBox isnt "block")
							addFace "nx",pos
						if (@cellTerrain.getBlock(pos[0]-1,pos[1],pos[2]).boundingBox isnt "block")
							addFace "px",pos
						if (@cellTerrain.getBlock(pos[0],pos[1]-1,pos[2]).boundingBox isnt "block")
							addFace "ny",pos
						if (@cellTerrain.getBlock(pos[0],pos[1]+1,pos[2]).boundingBox isnt "block")
							addFace "py",pos
						if (@cellTerrain.getBlock(pos[0],pos[1],pos[2]+1).boundingBox isnt "block")
							addFace "pz",pos
						if (@cellTerrain.getBlock(pos[0],pos[1],pos[2]-1).boundingBox isnt "block")
							addFace "nz",pos
					else if @cellTerrain.getBlock(pos...).name is "water"
						if (@cellTerrain.getBlock(pos[0]+1,pos[1],pos[2]).name is "air")
							addFace "nx",pos
						if (@cellTerrain.getBlock(pos[0]-1,pos[1],pos[2]).name is "air")
							addFace "px",pos
						if (@cellTerrain.getBlock(pos[0],pos[1]-1,pos[2]).name is "air")
							addFace "ny",pos
						if (@cellTerrain.getBlock(pos[0],pos[1]+1,pos[2]).name is "air")
							addFace "py",pos
						if (@cellTerrain.getBlock(pos[0],pos[1],pos[2]+1).name is "air")
							addFace "pz",pos
						if (@cellTerrain.getBlock(pos[0],pos[1],pos[2]-1).name is "air")
							addFace "nz",pos
		return {
			positions
			normals
			uvs
			colors
		}

addEventListener "message", (e)->
	fn = handlers[e.data.type]
	if not fn
		throw new Error('no handler for type: ' + e.data.type)
	fn(e.data.data)
	return
State={
	init:null
	world:{}
}
terrain=null
time=0
handlers={
	init:(data)->
		State.init=data
		terrain=new TerrainManager {
			models:data.models
			blocks:data.blocks
			blocksMapping:data.blocksMapping
			toxelSize:data.toxelSize
			cellSize:data.cellSize
		}
		return
	setVoxel:(data)->
		terrain.cellTerrain.setVoxel data...
	genCellGeo: (data)->
		if ((terrain.cellTerrain.vec3 data...) of terrain.cellTerrain.cells) is true
			geo=terrain.genCellGeo data...
			postMessage {
				cell:geo
				info:data
			}
	setCell: (data)->
		terrain.cellTerrain.setCell data[0],data[1],data[2],data[3]
		terrain.cellTerrain.setBiome data[0],data[1],data[2],data[4]
}
