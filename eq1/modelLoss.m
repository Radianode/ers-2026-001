function [loss,gradients] = modelLoss(net,X,Y)

YPred = forward(net,X);

loss = mse(YPred,Y);

gradients = dlgradient(loss,net.Learnables);

end