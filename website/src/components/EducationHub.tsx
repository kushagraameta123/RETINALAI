import { BookOpen, Search } from 'lucide-react';
import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { supabase } from '../services/supabaseClient';
import { Badge } from './ui/badge';
import { Button } from './ui/button';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Input } from './ui/input';

const EducationHub = () => {
  const [articles, setArticles] = useState([]);
  const [filteredArticles, setFilteredArticles] = useState([]);
  const [categories, setCategories] = useState([]);
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [searchTerm, setSearchTerm] = useState('');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchArticles = async () => {
      setIsLoading(true);
      const { data, error } = await supabase
        .from('educational_content')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) {
        console.error('Error fetching articles:', error);
      } else {
        setArticles(data);
        setFilteredArticles(data);
        const uniqueCategories = ['All', ...new Set(data.map(article => article.category))];
        setCategories(uniqueCategories);
      }
      setIsLoading(false);
    };
    fetchArticles();
  }, []);

  useEffect(() => {
    let result = articles;
    if (selectedCategory !== 'All') {
      result = result.filter(article => article.category === selectedCategory);
    }
    if (searchTerm) {
      result = result.filter(article => 
        article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        article.content.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }
    setFilteredArticles(result);
  }, [selectedCategory, searchTerm, articles]);

  return (
    <div className="container mx-auto py-8 px-4">
      <div className="text-center mb-12">
        <BookOpen className="h-16 w-16 text-[#0A3D62] mx-auto mb-4" />
        <h1 className="text-4xl font-bold text-[#0A3D62]">Health Education Center</h1>
        <p className="text-lg text-muted-foreground mt-2">
          Browse articles and resources about retinal health and disease prevention.
        </p>
      </div>

      <div className="mb-8 flex flex-col md:flex-row gap-4 items-center">
        <div className="flex flex-wrap gap-2">
          {categories.map(category => (
            <Button
              key={category}
              variant={selectedCategory === category ? 'default' : 'outline'}
              onClick={() => setSelectedCategory(category)}
            >
              {category}
            </Button>
          ))}
        </div>
        <div className="relative w-full md:w-auto md:ml-auto">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
          <Input 
            placeholder="Search articles..."
            className="pl-10"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
        </div>
      </div>

      {isLoading ? (
        <p className="text-center">Loading articles...</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {filteredArticles.length > 0 ? filteredArticles.map(article => (
            <Card key={article.id} className="hover:shadow-lg transition-shadow flex flex-col">
              <CardHeader>
                <Badge variant="secondary" className="mb-2 w-fit">{article.category}</Badge>
                <CardTitle>{article.title}</CardTitle>
              </CardHeader>
              <CardContent className="flex flex-col flex-grow">
                <p className="text-muted-foreground line-clamp-4 flex-grow">
                  {article.content}
                </p>
                <Link to={`/education/${article.id}`} className="mt-4">
                  <Button className="w-full">Read More</Button>
                </Link>
              </CardContent>
            </Card>
          )) : (
            <p className="text-center col-span-3 text-muted-foreground">No articles found. Try adjusting your search or filter.</p>
          )}
        </div>
      )}
    </div>
  );
};

export default EducationHub;

