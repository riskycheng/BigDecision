import React, { useState, useEffect } from 'react';
import { TextField, Button, Snackbar, Stepper, Step, StepLabel } from '@mui/material';
import { useNavigate } from 'react-router-dom';

function NewDecisionPage() {
  const navigate = useNavigate();
  
  // 状态定义
  const [decisionTitle, setDecisionTitle] = useState('');
  const [optionA, setOptionA] = useState('');
  const [optionB, setOptionB] = useState('');
  const [additionalInfo, setAdditionalInfo] = useState('');
  const [analysisResult, setAnalysisResult] = useState(null);
  const [activeStep, setActiveStep] = useState(0);
  const [completedSteps, setCompletedSteps] = useState({0: false, 1: false, 2: false});
  const [actionButtonText, setActionButtonText] = useState('取消');
  const [snackbarOpen, setSnackbarOpen] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  // 处理步骤变化
  const handleStepChange = (newStep) => {
    setActiveStep(newStep);
    
    // 当进入第三步时，自动将其标记为完成
    if (newStep === 2) {
      setCompletedSteps(prev => ({
        ...prev,
        2: true
      }));
      setActionButtonText("完成");
    }
  };
  
  // 第一步组件
  function FirstStep() {
    return (
      <div className="first-step-container">
        <TextField
          label="决定标题"
          value={decisionTitle}
          onChange={(e) => setDecisionTitle(e.target.value)}
          fullWidth
          margin="normal"
          required
        />
        
        <TextField
          label="选项A"
          value={optionA}
          onChange={(e) => setOptionA(e.target.value)}
          fullWidth
          margin="normal"
          required
        />
        
        <TextField
          label="选项B"
          value={optionB}
          onChange={(e) => setOptionB(e.target.value)}
          fullWidth
          margin="normal"
          required
        />
      </div>
    );
  }
  
  // 第二步组件
  function SecondStep() {
    return (
      <div className="second-step-container">
        <TextField
          label="补充信息"
          value={additionalInfo}
          onChange={(e) => setAdditionalInfo(e.target.value)}
          fullWidth
          multiline
          rows={4}
          margin="normal"
        />
        
        <Button 
          variant="contained" 
          color="primary"
          onClick={handleStartAnalysis}
          className="start-analysis-button"
        >
          开始分析
        </Button>
      </div>
    );
  }
  
  // 第三步组件
  function ThirdStep() {
    return (
      <div className="third-step-container">
        {/* 分析结果展示 */}
        <div className="analysis-result">
          {analysisResult ? (
            <div>
              <h3>分析结果</h3>
              <p>{analysisResult}</p>
            </div>
          ) : (
            <p>正在加载分析结果...</p>
          )}
        </div>
        
        <div className="action-buttons">
          <Button 
            variant="contained" 
            onClick={handleShare}
            className="action-button"
          >
            分享
          </Button>
          
          <Button 
            variant="contained" 
            onClick={handleFavorite}
            className="action-button"
          >
            收藏
          </Button>
          
          <Button 
            variant="contained" 
            onClick={handleReanalyze}
            className="action-button"
          >
            重新分析
          </Button>
          
          <Button 
            variant="contained" 
            onClick={handleExport}
            className="action-button"
          >
            导出
          </Button>
        </div>
      </div>
    );
  }
  
  // 开始分析功能
  const handleStartAnalysis = async () => {
    // 模拟分析过程
    setAnalysisResult("正在分析...");
    
    try {
      // 这里可以添加实际的分析逻辑或API调用
      await new Promise(resolve => setTimeout(resolve, 1500));
      
      // 模拟分析结果
      setAnalysisResult(`基于您的输入，我们分析了"${decisionTitle}"的两个选项：
      
      选项A: ${optionA}
      选项B: ${optionB}
      
      考虑到您提供的补充信息：${additionalInfo || "无"}
      
      我们的建议是选择选项${Math.random() > 0.5 ? 'A' : 'B'}。`);
      
      // 分析完成后跳转到第三步
      handleStepChange(2);
    } catch (error) {
      console.error("分析失败:", error);
      setAnalysisResult("分析过程中出现错误，请重试。");
    }
  };
  
  // 分享功能
  const handleShare = () => {
    try {
      if (navigator.share) {
        navigator.share({
          title: decisionTitle,
          text: `我正在比较 ${optionA} 和 ${optionB}`,
          url: window.location.href,
        });
      } else {
        navigator.clipboard.writeText(window.location.href);
        setSnackbarMessage("链接已复制到剪贴板");
        setSnackbarOpen(true);
      }
    } catch (error) {
      console.error("分享失败:", error);
      setSnackbarMessage("分享失败");
      setSnackbarOpen(true);
    }
  };
  
  // 收藏功能
  const handleFavorite = () => {
    try {
      const decisionData = {
        id: Date.now().toString(),
        title: decisionTitle,
        optionA,
        optionB,
        additionalInfo,
        result: analysisResult,
        date: new Date().toISOString(),
      };
      
      const existingFavorites = JSON.parse(localStorage.getItem('favoriteDecisions') || '[]');
      localStorage.setItem('favoriteDecisions', JSON.stringify([...existingFavorites, decisionData]));
      
      setSnackbarMessage("决定已收藏");
      setSnackbarOpen(true);
    } catch (error) {
      console.error("收藏失败:", error);
      setSnackbarMessage("收藏失败");
      setSnackbarOpen(true);
    }
  };
  
  // 重新分析功能
  const handleReanalyze = () => {
    setActiveStep(1);
    setAnalysisResult(null);
    setCompletedSteps(prev => ({
      ...prev,
      2: false
    }));
    setActionButtonText("取消");
  };
  
  // 导出功能
  const handleExport = () => {
    try {
      const exportData = {
        title: decisionTitle,
        optionA,
        optionB,
        additionalInfo,
        result: analysisResult,
        date: new Date().toLocaleString(),
      };
      
      const dataStr = JSON.stringify(exportData, null, 2);
      const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
      const exportFileDefaultName = `${decisionTitle.replace(/\s+/g, '_')}_决定分析.json`;
      
      const linkElement = document.createElement('a');
      linkElement.setAttribute('href', dataUri);
      linkElement.setAttribute('download', exportFileDefaultName);
      linkElement.click();
      
      setSnackbarMessage("导出成功");
      setSnackbarOpen(true);
    } catch (error) {
      console.error("导出失败:", error);
      setSnackbarMessage("导出失败");
      setSnackbarOpen(true);
    }
  };
  
  // 取消功能
  const handleCancel = () => {
    if (window.confirm('确定要取消吗？您的所有输入将丢失。')) {
      navigate('/');
    }
  };
  
  // 完成功能
  const handleFinish = () => {
    handleFavorite();
    navigate('/');
  };
  
  // 渲染当前步骤内容
  const renderStepContent = () => {
    switch (activeStep) {
      case 0:
        return <FirstStep />;
      case 1:
        return <SecondStep />;
      case 2:
        return <ThirdStep />;
      default:
        return <div>未知步骤</div>;
    }
  };
  
  // 处理下一步按钮
  const handleNext = () => {
    if (activeStep === 0) {
      if (!decisionTitle || !optionA || !optionB) {
        setSnackbarMessage("请填写所有必填字段");
        setSnackbarOpen(true);
        return;
      }
      
      setCompletedSteps(prev => ({
        ...prev,
        0: true
      }));
    }
    
    handleStepChange(activeStep + 1);
  };
  
  // 处理上一步按钮
  const handleBack = () => {
    handleStepChange(activeStep - 1);
  };
  
  return (
    <div className="new-decision-container">
      <div className="stepper-container">
        <Stepper activeStep={activeStep}>
          <Step completed={completedSteps[0]}>
            <StepLabel>基本信息</StepLabel>
          </Step>
          <Step completed={completedSteps[1]}>
            <StepLabel>补充信息</StepLabel>
          </Step>
          <Step completed={completedSteps[2]}>
            <StepLabel>分析结果</StepLabel>
          </Step>
        </Stepper>
        
        <div className="action-button-container">
          <Button 
            variant="contained" 
            color="primary"
            onClick={activeStep === 2 ? handleFinish : handleCancel}
          >
            {activeStep === 2 ? "完成" : "取消"}
          </Button>
        </div>
      </div>
      
      {/* 步骤内容 */}
      <div className="step-content">
        {renderStepContent()}
      </div>
      
      {/* 导航按钮 */}
      {activeStep !== 2 && (
        <div className="navigation-buttons">
          <Button 
            disabled={activeStep === 0}
            onClick={handleBack}
          >
            上一步
          </Button>
          
          {activeStep === 0 && (
            <Button 
              variant="contained" 
              color="primary"
              onClick={handleNext}
            >
              下一步
            </Button>
          )}
        </div>
      )}
      
      {/* 通知组件 */}
      <Snackbar
        open={snackbarOpen}
        autoHideDuration={3000}
        onClose={() => setSnackbarOpen(false)}
        message={snackbarMessage}
      />
    </div>
  );
}

export default NewDecisionPage; 