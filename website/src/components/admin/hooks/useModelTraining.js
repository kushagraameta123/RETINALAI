import { useState, useEffect } from 'react';
import { 
  MODEL_CONFIG_DEFAULTS, 
  MODEL_VERSIONS_DATA, 
  TRAINING_HISTORY_DATA, 
  DATASET_INFO_DATA, 
  SYSTEM_RESOURCES_DATA, 
  TRAINING_LOGS_DATA, 
  MODEL_METRICS_INITIAL 
} from '../constants/aiModelConstants';

export function useModelTraining() {
  const [activeTab, setActiveTab] = useState('overview');
  const [trainingStatus, setTrainingStatus] = useState('idle');
  const [currentEpoch, setCurrentEpoch] = useState(0);
  const [totalEpochs, setTotalEpochs] = useState(30);
  const [trainingProgress, setTrainingProgress] = useState(0);
  const [modelMetrics, setModelMetrics] = useState(MODEL_METRICS_INITIAL);
  const [modelConfig, setModelConfig] = useState(MODEL_CONFIG_DEFAULTS);
  const [modelVersions, setModelVersions] = useState(MODEL_VERSIONS_DATA);
  const [trainingHistory] = useState(TRAINING_HISTORY_DATA);
  const [datasetInfo] = useState(DATASET_INFO_DATA);
  const [systemResources] = useState(SYSTEM_RESOURCES_DATA);
  const [trainingLogs, setTrainingLogs] = useState(TRAINING_LOGS_DATA);

  // Simulate training progress
  useEffect(() => {
    let interval;
    if (trainingStatus === 'training') {
      interval = setInterval(() => {
        setTrainingProgress(prev => {
          const newProgress = Math.min(prev + 2, 100);
          if (newProgress >= 100) {
            setTrainingStatus('completed');
            setCurrentEpoch(totalEpochs);
          }
          return newProgress;
        });
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [trainingStatus, totalEpochs]);

  const addLog = (level, message) => {
    const newLog = {
      timestamp: new Date().toLocaleString(),
      level,
      message
    };
    setTrainingLogs(prev => [newLog, ...prev]);
  };

  const handleStartTraining = () => {
    setTrainingStatus('training');
    setTrainingProgress(0);
    setCurrentEpoch(0);
    addLog('INFO', `Training started - Fusion Model (${modelConfig.branch1} + ${modelConfig.branch2})`);
  };

  const handlePauseTraining = () => {
    setTrainingStatus('paused');
    addLog('WARNING', 'Training paused by user');
  };

  const handleStopTraining = () => {
    setTrainingStatus('stopped');
    setTrainingProgress(0);
    addLog('ERROR', 'Training stopped by user');
  };

  const handleDeployModel = (versionId) => {
    setModelVersions(prev => prev.map(version => ({
      ...version,
      status: version.id === versionId ? 'deployed' : 
              version.status === 'deployed' ? 'archived' : version.status,
      deployedAt: version.id === versionId ? new Date().toISOString() : version.deployedAt
    })));
    
    addLog('SUCCESS', `Model ${versionId} deployed to production`);
  };

  return {
    // State
    activeTab,
    trainingStatus,
    currentEpoch,
    totalEpochs,
    trainingProgress,
    modelMetrics,
    modelConfig,
    modelVersions,
    trainingHistory,
    datasetInfo,
    systemResources,
    trainingLogs,
    
    // Actions
    setActiveTab,
    setTotalEpochs,
    setModelConfig,
    handleStartTraining,
    handlePauseTraining,
    handleStopTraining,
    handleDeployModel
  };
}