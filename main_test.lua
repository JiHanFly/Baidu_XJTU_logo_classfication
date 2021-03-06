require 'torch'
require 'image'
require 'nn'
require 'cudnn'
require 'cunn'
require 'optim'
require 'gnuplot'
require 'cutorch'
csv = require 'csvigo'
cutorch.setDevice(1)

batchsize = 1

torch.setdefaulttensortype('torch.CudaTensor')

-- set paths
imgpath = paths.concat('/home/zxw/Baidu/datasets/Test_PaddedImage/','%s')

model_opt = {}

-- Annotation Fetcher

function getImage(i)
  return image.load(getImagePath(i),3,'float')
end

function getImagePath(i)
  return string.format(imgpath,i)
end

modelpara = 'ResNet5e-4_NoFlip'

net = torch.load('/home/zxw/Baidu/TrainedModel/'..modelpara..'/100Class_ResNet1000iteration.t7')   -- the directory which save the model

csvf = csv.File(modelpara..'1000_result.csv', "w"," ")
txtf = io.open(modelpara..'1000_NoFlip_result.txt','w')
--[[for i = 1,100 do
     os.execute('mkdir /data/Cmp/datasets/Classifier/'..i)
end
--]]
for data in io.lines('/home/zxw/Baidu/datasets/test/imagename.txt') do
      --print(batchsize)   
      local inputs = torch.CudaTensor(batchsize,3,224,224)
      local Predict = torch.CudaTensor(batchsize)

      for t = 1,batchsize do
                 temp = getImage(data)
		 inputs[{{t},{},{},{}}] =image.scale(temp,224,224)
      end
      for i=1,3 do -- over each image channel
                 mean=inputs[{ {}, {i}, {} ,{}  }]:mean() -- mean estimation
                 inputs[{ {}, {i}, {}, {}  }]:add(-mean) -- mean subtraction
      end
      outputs = net:forward(inputs:cuda())

      index,Predict = torch.max(outputs,2)
      print(data,torch.squeeze(Predict))
      txtf:write(data..' '..torch.squeeze(Predict)..'\n')
      --os.execute('cp /data/Cmp/datasets/test/'..data..' /data/Cmp/datasets/Classifier/'..torch.squeeze(Predict)..'/'..data)
      --image.save(,temp)
      csvf:write({data, torch.squeeze(Predict)})
end
txtf:close()
csvf:close()
