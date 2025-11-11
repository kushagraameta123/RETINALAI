import React from 'react';
import { Button } from '../../ui/button';
import { Badge } from '../../ui/badge';
import { Play, Pause, Square } from 'lucide-react';
import { getStatusColor } from '../constants/aiModelConstants';

export default function TrainingControls({ 
  trainingStatus, 
  onStart, 
  onPause, 
  onStop 
}) {
  return (
    <div className="flex items-center space-x-4">
      <Badge variant={trainingStatus === 'training' ? 'default' : 'secondary'} className="text-sm">
        <div className={`w-2 h-2 rounded-full mr-2 ${getStatusColor(trainingStatus)}`}></div>
        {trainingStatus.charAt(0).toUpperCase() + trainingStatus.slice(1)}
      </Badge>
      <div className="flex space-x-2">
        {trainingStatus === 'idle' || trainingStatus === 'stopped' ? (
          <Button onClick={onStart} className="bg-medical-blue hover:bg-medical-blue-light">
            <Play className="w-4 h-4 mr-2" />
            Start Training
          </Button>
        ) : trainingStatus === 'training' ? (
          <>
            <Button onClick={onPause} variant="outline">
              <Pause className="w-4 h-4 mr-2" />
              Pause
            </Button>
            <Button onClick={onStop} variant="destructive">
              <Square className="w-4 h-4 mr-2" />
              Stop
            </Button>
          </>
        ) : (
          <Button onClick={onStart} className="bg-medical-blue hover:bg-medical-blue-light">
            <Play className="w-4 h-4 mr-2" />
            Resume
          </Button>
        )}
      </div>
    </div>
  );
}