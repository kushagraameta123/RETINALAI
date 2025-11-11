import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { supabase } from '../services/supabaseClient';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Badge } from './ui/badge';
import { ArrowLeft } from 'lucide-react';
import ReactMarkdown from 'react-markdown'; // You need to install this!

const ArticlePage = () => {
  const { articleId } = useParams(); // Gets the ID from the URL
  const [article, setArticle] = useState(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchArticle = async () => {
      if (!articleId) return;
      setIsLoading(true);
      const { data, error } = await supabase
        .from('educational_content')
        .select('*')
        .eq('id', articleId)
        .single(); // Fetch only one record

      if (error) {
        console.error('Error fetching article:', error);
      } else {
        setArticle(data);
      }
      setIsLoading(false);
    };
    fetchArticle();
  }, [articleId]);

  if (isLoading) {
    return <div className="text-center py-20">Loading article...</div>;
  }
  
  if (!article) {
    return <div className="text-center py-20">Article not found.</div>;
  }

  return (
    <div className="container mx-auto py-12 px-4 max-w-4xl">
      <Link to="/education" className="flex items-center text-medical-blue mb-8 hover:underline">
        <ArrowLeft className="w-4 h-4 mr-2" />
        Back to all articles
      </Link>
      
      <Card>
        <CardHeader>
          <Badge variant="secondary" className="mb-4 w-fit">{article.category}</Badge>
          <CardTitle className="text-3xl">{article.title}</CardTitle>
          <p className="text-muted-foreground pt-2">
            Published on {new Date(article.created_at).toLocaleDateString()}
          </p>
        </CardHeader>
        <CardContent className="prose max-w-none">
          {/* This will render the article content as formatted text */}
          <ReactMarkdown>{article.content}</ReactMarkdown>
        </CardContent>
      </Card>
    </div>
  );
};

export default ArticlePage;