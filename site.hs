--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import 	         Text.Pandoc


--------------------------------------------------------------------------------
config :: Configuration
config = defaultConfiguration
         { deployCommand = "rsync -avz -e 'ssh -i ~/.ssh/id_rsa_2' ./_site/ root@ginbaby:/var/www/ginbaby/" }

main :: IO ()
main = hakyllWith config $ do
  match "static/*/*" $ do
	route idRoute
	compile copyFileCompiler

  match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
	    >>= loadAndApplyTemplate "templates/page.html" siteCtx
            >>= loadAndApplyTemplate "templates/default.html" siteCtx
            >>= relativizeUrls

  match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

  create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    siteCtx

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


  match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Home"                `mappend`
                    siteCtx

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

  match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y" `mappend`
    siteCtx

siteCtx :: Context String
siteCtx =
    constField "baseurl" "http://ginbaby.me" `mappend`
    constField "site_description" "stories" `mappend`
    constField "instagram_username" "juliemoronuki" `mappend`
    constField "twitter_username" "argumatronic" `mappend`
    constField "github_username" "GinBaby" `mappend`
    -- constField "google_username" "katychuang" `mappend`
    defaultContext
